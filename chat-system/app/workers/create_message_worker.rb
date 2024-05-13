class CreateMessageWorker
  include Sidekiq::Worker

  def perform(app_id, chat_id, message_id, message)
    new_message = Message.new(appID: app_id, chatID: chat_id, messageID: message_id, message: message)
    if new_message.save
      # Record was successfully saved
      puts "Record saved successfully!"
    else
      # Failed to save the record
      puts "Failed to save record: #{new_message.errors.full_messages.join(', ')}"
    end
  end
end