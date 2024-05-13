class CreateMessageWorker
  include Sidekiq::Worker

  def perform(app_id, chat_id, message_id, message)
    Message.create(appID: app_id, chatID: chat_id, messageID: message_id, message: message)
  end
end