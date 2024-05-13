class CreateChatWorker
    include Sidekiq::Worker
    # sidekiq_options queue: "task_queue"
  
    def perform(app_id, chat_id)
        Chat.create(appID: app_id, chatID: chat_id)
        puts "finished creation of entry in db with ID: #{app_id} and ChatID: #{chat_id}"
    end
end
  