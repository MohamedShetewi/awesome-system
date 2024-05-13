class UpdateChatsCountWorker
    include Sidekiq::Worker
  
    def perform(app_id, new_chat_count)
        Application.find_by(appID: app_id).update(chatsCount: new_chat_count)
        puts "Updated chat count for application ID: #{app_id} to #{new_chat_count}"
    end
end
  