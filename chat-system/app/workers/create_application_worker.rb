class CreateApplicationWorker
    include Sidekiq::Worker
    # sidekiq_options queue: "task_queue"
  
    def perform(app_id, username)
      Application.create(appID: app_id, username: username, chatsCount: 0)
    end

  end
  