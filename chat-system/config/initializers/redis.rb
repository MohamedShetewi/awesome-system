require 'redis'

# Create a new Redis client
redis = Redis.new(url: ENV['REDIS_URL'])

# Test the connection
begin
    redis.ping
    puts "Successfully connected to Redis!"
rescue Redis::CannotConnectError => e
    puts "Failed to connect to Redis: #{e.message}"
end