class ChatController < ActionController::Base
    skip_before_action :verify_authenticity_token
   
    def show
        # Logic to fetch a specific chat
        chat = Chat.find(params[:app_id], params[:chat_id])
        render json: {"Application":chat.appID, "Chat": chat.chatID, "MessagesCount": chat.messagesCount}
    end

    # POST /application/:app_id/chat
    def create
        # Logic to create a new chat
        #check if app exists from redis
        if params[:app_id].nil? || params[:app_id].empty?
            render json: {"error": "Application ID is required"}, status: 400
        else
            if $redis.get("app:#{params[:app_id]}").nil?
                render json: {"error": "Application not found"}, status: 404
            else 
                chat_id = $redis.incr("app:#{params[:app_id]}:chats_count")
                
                CreateChatWorker.perform_async(params[:app_id], chat_id)
                UpdateChatsCountWorker.perform_async(params[:app_id], chat_id)

                puts "Added a task to create a chat with ID: #{chat_id} for application ID: #{params[:app_id]}"
                render json: {"Application": params[:app_id], "Chat": chat_id}
            end
        end
    end
end