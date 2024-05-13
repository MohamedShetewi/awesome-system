class CreateChatWorker
    include Sidekiq::Worker
    # sidekiq_options queue: "task_queue"
  
    def perform(app_id, chat_id)
        new_chat = Chat.new(appID: app_id, chatID: chat_id)
        if new_chat.save
            # Record was successfully saved
            puts "Record saved successfully!"
        else
            # Failed to save the record
            puts "Failed to save record: #{new_chat.errors.full_messages.join(', ')}"
        end
    end
end
  