require 'json'

class CreateMessageWorker
  include Sidekiq::Worker

  def perform(app_id, chat_id, message_id, message)
	elasticsearchResult = $elasticsearchClient.index(index: 'messages', 
	  body: { 
		appID: app_id, 
		chatID: chat_id,
		messageID: message_id,
		message: message,
	})
	puts elasticsearchResult

	if elasticsearchResult["result"] == "created"
		elasticsearch_id = elasticsearchResult["_id"]
		puts "Elasticsearch ID: #{elasticsearch_id}"
		new_message = Message.new(appID: app_id, chatID: chat_id, messageID: message_id,
								  message: message, elasticsearchID: elasticsearch_id)
		if new_message.save!
			puts "Record saved successfully!"
		else
			puts "Failed to save record: #{new_message.errors.full_messages.join(', ')}"
		end
	else
		raise "Failed to save record: #{elasticsearchResult}"
	end
  end
end


