class ChatController < ActionController::Base
    def show
        # Logic to fetch a specific chat
        @chat = Chat.find(params[:app_id], params[:chat_id])
        render json: {"Application":chat.appID, "Chat": chat.chatID}
    end
end