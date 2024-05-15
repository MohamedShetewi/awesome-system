# awesome-system
This is a chat system that allows user to create applications, chats and messages. Also, it allows the user to search for
messages in a chat.

## System Components

### Ruby service
This is our main application. It has APIs to create and get Applications, Chats and Messages. It is connected
to the MySQL db, Redis (for caching and queueing) and Elasticsearch. All creation and update APIs are served asyncronously.
### Golang Service
 This is a creation service. It just creates chats and messages. It is connected to redis to update and get ids of different entities.
### MySQL
This is the main database. It stores all the data that is used by the Ruby Service. 
### Redis
This is used by the Ruby Service and Golang Service for caching and queueing.
### Elasticsearch
This is used by the Ruby Service to store the messages that are created. It is used then for searching in messages.


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


## Database Schema
## How to run it?
