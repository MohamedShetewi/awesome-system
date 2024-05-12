require 'securerandom'

class ApplicationController < ActionController::Base

    skip_before_action :verify_authenticity_token

    def show 
        # Logic to fetch a specific application
        @application = Application.find_by(appID: params[:app_id])
        render json: {"Application": @application.appID, "Username": @application.username, "ChatsCount": @application.chatsCount}
    end

    def create
        # Logic to create a new application
        appID = SecureRandom.hex(4)
        username = params[:username]
        
        # Create a new application
        # put the new application in a queue for processing
        #
        Application.create(appID: appID, username: username, chatsCount: 0)
        render json: {"Application": appID, "Username": username}
    end
end
