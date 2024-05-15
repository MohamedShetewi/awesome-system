package main

import (
	"encoding/json"
	"fmt"
	"github.com/gorilla/mux"
	"log"
	"net/http"
	"strconv"
	"time"
)

const (
	// chatsCounterKey is the key to store the chats count
	chatsCounterKeyTemplate  = "app:%s:chats_count"
	messagesCountKeyTemplate = "app:%s:chat:%d:messages_count"
)

type CreateMessageRequest struct {
	Message string `json:"message"`
}

type Server struct {
	cache    Cache
	jobQueue JobQueue
}

func NewServer(cache Cache, jobQueue JobQueue) *Server {
	return &Server{
		cache:    cache,
		jobQueue: jobQueue,
	}
}

// HandleChatCreation handles the creation of a chat
// POST /application/{appToken}/chat
func (s *Server) HandleChatCreation(w http.ResponseWriter, req *http.Request) {
	log.Println("HandleChatCreation")
	createdAt := float64(time.Now().Second())
	// get appToken
	vars := mux.Vars(req)
	appToken := vars["appToken"]
	log.Println("HandleChatCreation -> appToken: " + appToken)

	chatCountKey := fmt.Sprintf(chatsCounterKeyTemplate, appToken)
	if _, err := s.cache.Get(chatCountKey); err != nil {
		log.Println("HandleChatCreation -> Application not found")
		http.Error(w, "Application not found", http.StatusNotFound)
		return
	}
	chatID, err := s.cache.Incr(chatCountKey)
	if err != nil {
		log.Println("HandleChatCreation -> Application not found")
		http.Error(w, "Error occured while increamenting", http.StatusNotFound)
		return
	}

	// enqueue create chat job
	if err := s.jobQueue.EnqueueCreateChatJob(appToken, chatID, createdAt); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// return chatID
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]any{"appID": appToken, "chatID": chatID})
}

// HandleMessageCreation handles the creation of a message
// POST /application/{appToken}/chat/{chatID}/message
// Request Body: {"message": "Hello World"}
func (s *Server) HandleMessageCreation(w http.ResponseWriter, req *http.Request) {
	createdAt := float64(time.Now().Second())
	// get appToken
	vars := mux.Vars(req)
	appToken, ok := vars["appToken"]
	if !ok {
		log.Println("HandleMessageCreation -> appToken not found")
		http.Error(w, "appToken not found", http.StatusBadRequest)
		return
	}
	chatIDstr, ok := vars["chatID"]
	if !ok {
		log.Println("HandleMessageCreation -> chatID not found")
		http.Error(w, "chatID not found", http.StatusBadRequest)
		return
	}
	// get chatID in int64
	chatID, err := strconv.ParseInt(chatIDstr, 10, 64)
	if err != nil {
		log.Println("HandleMessageCreation -> Error parsing chatID" + err.Error())
		http.Error(w, "Error parsing chatID", http.StatusBadRequest)
		return
	}

	// get request body
	var createMessageRequest CreateMessageRequest
	if err := json.NewDecoder(req.Body).Decode(&createMessageRequest); err != nil {
		log.Println("HandleMessageCreation -> Error decoding request body")
		http.Error(w, "Error decoding request body", http.StatusBadRequest)
		return
	}
	log.Printf("Request to create message: %s appID: %s chatID: %d", createMessageRequest.Message, appToken, chatID)

	// check if application and chat exists
	messageCountKey := fmt.Sprintf(messagesCountKeyTemplate, appToken, chatID)
	log.Println("messageCountKey: " + messageCountKey)
	if _, err := s.cache.Get(messageCountKey); err != nil {
		log.Println("HandleMessageCreation -> Chat not found or application not found")
		http.Error(w, "Application not found", http.StatusNotFound)
		return
	}

	// increment message count
	messageID, err := s.cache.Incr(messageCountKey)
	if err != nil {
		log.Println("HandleMessageCreation -> Error occured while increamenting")
		http.Error(w, "Error occured while increamenting", http.StatusInternalServerError)
		return
	}
	log.Println("HandleMessageCreation -> messagesCountInStr: " + fmt.Sprintf("%d", messageID))

	// create a messageID
	// enqueue create message job
	if err := s.jobQueue.EnqueueCreateMessageJob(appToken, chatID, messageID, createMessageRequest.Message, createdAt); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// return messageID
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]any{"appID": appToken, "chatID": chatID, "messageID": messageID})
}
