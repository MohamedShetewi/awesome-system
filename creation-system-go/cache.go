package main

import (
	"context"

	redisClient "github.com/redis/go-redis/v9"
)

var _ Cache = (*redis)(nil)

type Cache interface {
	Get(key string) (string, error)
	Incr(key string) (int64, error)
}

type redis struct {
	// redis connection
	redisClient *redisClient.Client
}

func NewRedisCache(redisClient *redisClient.Client) Cache {
	return &redis{
		redisClient: redisClient,
	}
}

func (r *redis) Get(key string) (string, error) {
	ctx := context.Background()
	return r.redisClient.Get(ctx, key).Result()
}

func (r *redis) Incr(key string) (int64, error) {
	ctx := context.Background()
	return r.redisClient.Incr(ctx, key).Result()
}
