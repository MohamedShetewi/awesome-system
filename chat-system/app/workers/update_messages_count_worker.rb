class UpdateMessagesCountWorker
  	include Sidekiq::Worker

	def perform(app_id, chat_id,messages_count)
		Chat.find_by(appID: app_id, chatID: chat_id).update(messagesCount: messages_count)
		puts "Updated chat count for application ID: #{app_id} to #{messages_count}"
	end
end
