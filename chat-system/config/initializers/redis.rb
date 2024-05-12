require 'redis'


# Connect to Redis
$redis = Redis.new(url: ENV["REDIS_URL"])