package main

import (
	"log"
	"net/http"
	"os"

	"context"

	"github.com/gorilla/mux"
	redisClient "github.com/redis/go-redis/v9"
)

func main() {
	redisConnection := os.Getenv("REDIS_URL")
	if redisConnection == "" {
		redisConnection = "localhost:6379"
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8000"
	}

	redisClient := redisClient.NewClient(&redisClient.Options{
		Addr: redisConnection,
	})
	// make sure the connection is ok
	_, err := redisClient.Ping(context.Background()).Result()
	if err != nil {
		panic(err)
	}
	log.Println("Connected to Redis!!")
	// create cache
	cache := NewRedisCache(redisClient)

	// create job queue
	jobQueue := NewSidekiq(redisClient)

	server := NewServer(cache, jobQueue)

	r := mux.NewRouter()
	r.HandleFunc("/", func(w http.ResponseWriter, req *http.Request) {
		w.Write([]byte("Hello World"))
	}).Methods("GET")
	r.HandleFunc("/application/{appToken}/chat", server.HandleChatCreation).Methods("POST")
	r.HandleFunc("/application/{appToken}/chat/{chatID}/message", server.HandleMessageCreation).Methods("POST")

	http.ListenAndServe(":"+port, r)
}
