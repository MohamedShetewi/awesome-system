# awesome-system
This is a chat system that allows user to create applications, chats and messages. Also, it allows the user to search for
messages in a chat.

## System Components
![system](https://github.com/MohamedShetewi/awesome-system/blob/master/assets/System-components.png)


### Ruby service
This is our main application. It has APIs to create and get Applications, Chats and Messages. It is connected
to the MySQL db, Redis (for caching and queueing) and Elasticsearch. All creation and update APIs are served asyncronously.
### Golang Service
 This is a creation service. It just creates chats and messages. It is connected to redis to update and get ids of different entities.
### MySQL
This is the main database. It stores all the data that is used by the Ruby Service. 
### Redis
This is used by the Ruby Service and Golang Service for caching and queueing. Note that the cache is used for some of the apis not all of them.
### Elasticsearch
This is used by the Ruby Service to store the messages that are created. It is used then for searching in messages.

### Workers
This system uses [Sidekiq](https://github.com/sidekiq/sidekiq) to proccess the jobs asyncronously. It uses `redis` as the underlying queue.
#### CreateApplicationWorker
This worker is responsible for inserting the new application in `MySQL` db. A job is enqueued to this worker when `Create Application API` is hit.
#### CreateChatWorker
This worker inserts a new chat passed in the queue to `MySQL` db. This worker serves the `Create Chat API`.
#### CreateMessageWorker
This worker does exactly what previous workers do. However, it also inserts a new message to `Elasticsearch`
#### UpdateChatsCountWorker
This updates the `chatsCount` column in the `Application` table. This runs async after `Create Chat API`.
#### UpdateMessagesCountWorker
This also updates the `messagesCount` column in the `Message` table. However, this is called after `Create Message API`
#### UpdateMessageWorker
This worker is responsible to update the messages in 2 places, first the `Elasticsearch`. It gets the `_id` of the doc from `MySQL` db and 
then updates the `message` in `Elasticsearch`, and then updates the `MySQL` db entry. Note that failing in this job could create duplicate
entries in `Elasticsearch` (for example, failing to insert in the db for some reason). This could be mitigated by a clean job that cleans the dangling records in `Elasticsearch`.

## Database Schema
![schema](https://github.com/MohamedShetewi/awesome-system/blob/master/assets/db-schema.png)

## How to run it?
1. Clone it `git clone https://github.com/MohamedShetewi/awesome-system`
2. Run `docker compose up`.
   1. Note that `Elasticsearch` takes sometime to start. So the `ruby-app` will keep restarting until `Elasticsearch` is ready.
3. `ruby-service` will be available on port `3001` and `go-service` will be on `8000`


## API Design
### Create Application
#### Request
```
POST /application
{
    "username": "Shetewi"
}
```
#### Response
```
{
    "Application": "dec969c6",
    "Username": "Shetewi"
}
```
#### Curl Sample Request
```
    curl --location 'http://localhost:3001/application' \
    --header 'Content-Type: application/json' \
    --data '{
        "username": "Shetewi"
    }'
```



### Get Application
#### Request
```
GET /application/:id
```
#### Response
```
{
    "Application": "7aa269eb",
    "Username": "Shetewi",
    "ChatsCount": "0"
}
```
#### Sample Request
```
curl --location 'localhost:3001/application/7aa269eb'
```

### Create Chat
#### Request
```
POST /application/:application_id/chats
```
#### Response
```
{
    "Application": "dec969c6",
    "Chat": 8
}
```
### Sample Request
Ruby Service
```
    curl --location --request POST 'localhost:3001/application/dec969c6/chat'
```
Golang Service
```
    curl --location --request POST 'localhost:8000/application/dec969c6/chat'
```


### Get Chat
#### Request
```
GET /application/:application_id/chat/:id
```
#### Response
```
{
    "Application": "dec969c6",
    "Chat": 5,
    "MessagesCount": null
}
```
#### Sample Request
```
    curl --location 'localhost:3001/application/dec969c6/chat/5'
```

### Create Message
#### Request
```
POST /application/:application_id/chat/:chat_id/message
{
  "message": "Hello, World!"
}
```
#### Response
```
{
    "Application": "dec969c6",
    "Chat": 5,
    "MessageID": 3,
    "Message": "Hello world again for the not last time"
}
```
#### Sample Request
Ruby Service
```
 curl --location 'localhost:3001/application/dec969c6/chat/5/message' \
 --header 'Content-Type: application/json' \
 --data '{"message":"Hello world again for the not last time"}'
```
Golang Service
```
 curl --location 'localhost:8000/application/dec969c6/chat/5/message' \
 --header 'Content-Type: application/json' \
 --data '{"message":"Alhamdulilah"}'
```
### Search for message
#### Request
```
GET application/:app_id/chat/:chat_id/search/:query
```
#### Response
```
[
    {
        "appID": "dec969c6",
        "chatID": 5,
        "messageID": 4,
        "message": "Alhamdulilah"
    },
    {
        "appID": "dec969c6",
        "chatID": 5,
        "messageID": 5,
        "message": "Alhamdulilah"
    }
]
```
#### Sample Request
```
curl --location 'localhost:3001/application/dec969c6/chat/5/search/Alhamdulilah'
``

### Get Message
#### Request
```
GET application/:app_id/chat/:chat_id/message/:message_id
```
#### Response
```
{
    "Application": "dec969c6",
    "Chat": 5,
    "MessageID": "3",
    "Message": "Guess what? Alhamdulilah"
}
```
#### Sample Request
```
curl --location 'localhost:3001/application/dec969c6/chat/5/message/3'
```
### Update Message
#### Request
```
  PUT application/:app_id/chat/:chat_id/message/:message_id
```
#### Response
```
{
    "status": "success"
}
```
#### Sample Request
```
 curl --location --request PUT 'localhost:3001/application/dec969c6/chat/5/message/3' \
 --header 'Content-Type: application/json' \
 --data '{"message": "Guess what? Alhamdulilah"}'
```
### Get All Messages in Chat
#### Request
```
application/:app_id/chat/:chat_id/messages
```
#### Response
```
{
    "status": "success"
}
```
or
```
{
    "error": "Message not found"
}
```
### Sample Request
```
 curl --location --request PUT 'localhost:3001/application/dec969c6/chat/5/message/3' \
 --header 'Content-Type: application/json' \
 --data '{"message": "Guess what? Alhamdulilah"}'
```
