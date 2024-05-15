package main

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"
	redisClient "github.com/redis/go-redis/v9"
)

const (
	defaultQueue          = "queue:default"
	createChatClass       = "CreateChatWorker"
	createMessageClass    = "CreateMessageWorker"
	updateChatsCountClass = "UpdateChatsCountWorker"
	updateMessagesCount   = "UpdateMessagesCountWorker"
)

type jobParam struct {
	Class      string  `json:"class"`
	Args       []any   `json:"args"`
	Retry      bool    `json:"retry"`
	Queue      string  `json:"queue"`
	Encrypt    bool    `json:"encrypt"`
	Jid        string  `json:"jid"`
	CreatedAt  float64 `json:"created_at"`
	EnqueuedAt float64 `json:"enqueued_at"`
}

var _ JobQueue = (*sidekiq)(nil)

type JobQueue interface {
	EnqueueCreateChatJob(appToken string, chatID int64, createdAt float64) error
	EnqueueCreateMessageJob(appToken string, chatID int64, messageID int64, messageBody string, createdAt float64) error
	EnqueueUpdateChatsCountJob(appToken string, chatsCount int64, createdAt float64) error
	EnqueueUpdateMessagesCountJob(appToken string, chatID int64, messagesCount int64, createdAt float64) error
}

type sidekiq struct {
	// redis connection
	redisClient *redisClient.Client
}

func NewSidekiq(redisClient *redisClient.Client) JobQueue {
	return &sidekiq{
		redisClient: redisClient,
	}
}

func (s *sidekiq) EnqueueCreateChatJob(appToken string, chatID int64, createdAt float64) error {

	// generate 24 character for jid
	jid := uuid.NewString()[0:24]
	jobParam := jobParam{
		Class:      createChatClass,
		Args:       []any{appToken, chatID},
		Retry:      true,
		Queue:      defaultQueue,
		Encrypt:    false,
		Jid:        jid,
		CreatedAt:  createdAt,
		EnqueuedAt: float64(time.Now().Second()),
	}
	payload, err := json.Marshal(jobParam)
	if err != nil {
		return err
	}
	_, err = s.redisClient.LPush(context.Background(), defaultQueue, payload).Result()
	return err
}

func (s *sidekiq) EnqueueCreateMessageJob(appToken string, chatID int64, messageID int64, messageBody string, createdAt float64) error {
	jid := uuid.NewString()[0:24]
	jobParam := jobParam{
		Class:      createMessageClass,
		Args:       []any{appToken, chatID, messageID, messageBody},
		Retry:      true,
		Queue:      defaultQueue,
		Encrypt:    false,
		Jid:        jid,
		CreatedAt:  createdAt,
		EnqueuedAt: float64(time.Now().Second()),
	}
	payload, err := json.Marshal(jobParam)
	if err != nil {
		return err
	}
	_, err = s.redisClient.LPush(context.Background(), defaultQueue, payload).Result()
	return err
}

func (s *sidekiq) EnqueueUpdateChatsCountJob(appToken string, chatsCount int64, createdAt float64) error {
	jid := uuid.NewString()[0:24]
	jobParam := jobParam{
		Class:      updateChatsCountClass,
		Args:       []any{appToken, chatsCount},
		Retry:      true,
		Queue:      defaultQueue,
		Encrypt:    false,
		Jid:        jid,
		CreatedAt:  createdAt,
		EnqueuedAt: float64(time.Now().Second()),
	}
	payload, err := json.Marshal(jobParam)
	if err != nil {
		return err
	}
	_, err = s.redisClient.LPush(context.Background(), defaultQueue, payload).Result()
	return err
}

func (s *sidekiq) EnqueueUpdateMessagesCountJob(appToken string, chatID int64, messagesCount int64, createdAt float64) error {
	jid := uuid.NewString()[0:24]
	jobParam := jobParam{
		Class:      updateMessagesCount,
		Args:       []any{appToken, chatID, messagesCount},
		Retry:      true,
		Queue:      defaultQueue,
		Encrypt:    false,
		Jid:        jid,
		CreatedAt:  createdAt,
		EnqueuedAt: float64(time.Now().Second()),
	}
	payload, err := json.Marshal(jobParam)
	if err != nil {
		return err
	}
	_, err = s.redisClient.LPush(context.Background(), defaultQueue, payload).Result()
	return err
}
