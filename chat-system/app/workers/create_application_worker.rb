class CreateApplicationWorker
    include Sidekiq::Worker
    # sidekiq_options queue: "task_queue"
  
    def perform(app_id, username)
      new_app = Application.new(appID: app_id, username: username, chatsCount: 0)
      if new_app.save
        # Record was successfully saved
        puts "Record saved successfully!"
      else
        # Failed to save the record
        puts "Failed to save record: #{new_app.errors.full_messages.join(', ')}"
      end
    end

  end
  