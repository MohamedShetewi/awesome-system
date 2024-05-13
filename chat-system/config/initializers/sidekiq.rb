Sidekiq.configure_server do |config|
    config.redis = { url: ENV['REDIS_URL'],    protocol: 2,} # Adjust the URL as needed
end
  
Sidekiq.configure_client do |config|
    config.redis = { url: ENV['REDIS_URL'],    protocol: 2,} # Adjust the URL as needed
end

puts "Successfully configured Sidekiq 6++ with Redis!"