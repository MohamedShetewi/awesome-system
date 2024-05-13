require 'securerandom'

class ApplicationController < ActionController::Base

    skip_before_action :verify_authenticity_token

    # GET /application/:app_id
    def show 
        # Logic to fetch a specific application
        @application = Application.find_by(appID: params[:app_id])
        render json: {"Application": @application.appID, "Username": @application.username, "ChatsCount": @application.chatsCount}
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
            puts "Application created with ID: #{appID} and Username: #{username}"
            render json: {"Application": appID, "Username": username}
        end
    end
end
