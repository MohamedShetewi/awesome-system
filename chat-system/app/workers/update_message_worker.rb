class UpdateMessageWorker
    include Sidekiq::Worker

    def perform(app_id, chat_id, message_id, new_message_text)
        message = Message.find_by(appID: app_id, chatID: chat_id, messageID: message_id)
        if message.nil?
            raise "Message not found"
        end
        elasticsearch_id = message.elasticsearchID

        elasticsearchResult = $elasticsearchClient.update(
            index: 'messages', 
            id: elasticsearch_id,
            body: { 
                doc: {message: new_message_text,}
        })

        puts elasticsearchResult
        if elasticsearchResult["result"] == "updated" || elasticsearchResult["result"] == "noop"
            message.update(message: new_message_text)
            if message.save!
                puts "Record updated successfully!"
            else
                puts "Failed to update record: #{message.errors.full_messages.join(', ')}"
            end
        else
            raise "Failed to update record: #{elasticsearchResult}"
        end
    end
end
