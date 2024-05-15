class MessageController < ActionController::Base
    
    skip_before_action :verify_authenticity_token

    # GET /application/:app_id/chat/:chat_id/message/:message_id
    def show
        app_id = params[:app_id]
        chat_id = params[:chat_id]
        message_id = params[:message_id]

        if app_id.nil? || app_id.empty?
            render json: {"error": "Application ID is required"}, status: 400
        elsif chat_id.nil? || chat_id.empty?
            render json: {"error": "Chat ID is required"}, status: 400
        elsif message_id.nil? || message_id.empty?
            render json: {"error": "Message ID is required"}, status: 400
        else
            message = Message.find_by(appID: app_id, chatID: chat_id, messageID: message_id)
            if message.nil?
                render json: {"error": "Message not found"}, status: 404
            else
                render json: {
                    "Application": app_id,
                    "Chat": chat_id,
                    "MessageID": message_id,
                    "Message": message.message,
                }
            end
        end
    end

    # POST /application/:app_id/chat/:chat_id/message
    def create
        app_id = params[:app_id]
        chat_id = params[:chat_id]
        message = params[:message]

        if app_id.nil? || app_id.empty?
            render json: {"error": "Application ID is required"}, status: 400
        elsif chat_id.nil? || chat_id.empty?
            render json: {"error": "Chat ID is required"}, status: 400
        elsif message.nil? || message.empty?
            render json: {"error": "Message is required"}, status: 400
        else
            if $redis.get("app:#{app_id}:chat:#{chat_id}:messages_count").nil?
                render json: {"error": "Chat not found"}, status: 404
            else     
                message_id = $redis.incr("app:#{app_id}:chat:#{chat_id}:messages_count")
                CreateMessageWorker.perform_async(app_id, chat_id, message_id, message)
                UpdateMessagesCountWorker.perform_async(app_id, chat_id, message_id)
                puts "Added a task to create a message for chat ID: #{chat_id}
                in application ID: #{app_id} 
                with message ID: #{message_id}
                and message: #{message}"
                render json: {
                    "Application": app_id,
                    "Chat": chat_id,
                    "MessageID": message_id,
                    "Message": message,
                }
            end
        end
    end
    
    def search
        app_id = params[:app_id]
        chat_id = params[:chat_id]
        query = params[:query]

        if $redis.get("app:#{params[:app_id]}:chat:#{chat_id}:messages_count").nil?
            render json: {"error": "Chat not found or App not found"}, status: 404
            return 
        end

        result = $elasticsearchClient.search(index: 'messages', body: {
            query: {
                bool: {
                    must: [
                    { match_phrase: { appID: app_id } },
                    { match_phrase: { chatID: chat_id } },
                    { match: { message: query } }
                    ]
                }
            }
        })
        searchResults = result['hits']['hits'].map { |hit| hit['_source'] }
        render json: searchResults
    end

    # PUT /application/:app_id/chat/:chat_id/message/:message_id
    def update
        app_id = params[:app_id]
        chat_id = params[:chat_id]
        message_id = params[:message_id]
        messageBody = params[:message]
        puts "Received a request to update a message with ID: #{message_id} for chat ID: #{chat_id} in application ID: #{app_id} with message: #{messageBody}"
        if app_id.nil? || app_id.empty?
            render json: {"error": "Application ID is required"}, status: 400
            return
        end
        if chat_id.nil? || chat_id.empty?
            render json: {"error": "Chat ID is required"}, status: 400
            return
        end
        if message_id.nil? || message_id.empty?
            render json: {"error": "Message ID is required"}, status: 400
            return
        end
        if messageBody.nil? || messageBody.empty?
            render json: {"error": "Message is required"}, status: 400
            return
        end
        if $redis.get("app:#{app_id}:chat:#{chat_id}:messages_count").nil?
            render json: {"error": "Chat not found"}, status: 404
            return
        end
            
        message = Message.find_by(appID: app_id, chatID: chat_id, messageID: message_id)
        if message.nil?
            render json: {"error": "Message not found"}, status: 404
            return
        end
        UpdateMessageWorker.perform_async(app_id, chat_id, message_id, messageBody)
        puts "Added a task to update a message with ID: #{message_id} for chat ID: #{chat_id} in application ID: #{app_id}"
        return render json: {
            "status": "success",}
    end
end