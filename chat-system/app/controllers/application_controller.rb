require 'securerandom'
require 'redis'

class ApplicationController < ActionController::Base

    skip_before_action :verify_authenticity_token

    # GET /application/:app_id
    def show 
        appID = params[:app_id]
        if appID.nil? || appID.empty?
            render json: {"error": "Application ID is required"}, status: 400
        else 
            # Logic to fetch a specific application
            key = "app:#{appID}"
            username = $redis.get(key)
            chats_count = $redis.get("app:#{appID}:chats_count")
        
            if username.nil? # If the application is not found in Redis, check the database
                app = Application.find_by(appID: appID)
                if app.nil?
                    render json: {"error": "Application not found"}, status: 404
                else
                    render json: {"Application": app.appID, "Username": app.username, "ChatsCount": chats_count}
                end
            else
                render json: {"Application": appID, "Username": username, "ChatsCount": chats_count}
            end
        end
    end

    # POST /application
    def create
        # Logic to create a new application
        appID = SecureRandom.hex(4)
        username = params[:username]
        if username.nil? || username.empty?
            render json: {"error": "Username is required"}, status: 400
        else
            CreateApplicationWorker.perform_async(appID, username)
            key = "app:#{appID}"
            application_chats_count = "app:#{appID}:chats_count"
            $redis.set(key, username)
            $redis.set(application_chats_count, 0)
            puts "Application created with ID: #{appID} and Username: #{username}"
            render json: {"Application": appID, "Username": username}
        end
    end
end
