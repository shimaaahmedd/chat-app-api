Sidekiq.configure_server do |config|
  config.redis = {host:'redis',url: ENV.fetch('REDIS_URL_SIDEKIQ', 'redis://localhost:6379/0') }
end
  
Sidekiq.configure_client do |config|
  config.redis = {host:'redis', url: ENV.fetch('REDIS_URL_SIDEKIQ', 'redis://localhost:6379/0') }
end