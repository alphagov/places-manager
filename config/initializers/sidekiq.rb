# This file will be overwritten on deployment
require "sidekiq"

if Rails.env
  namespace = "imminence-#{Rails.env}"
else
  namespace = "imminence"
end

redis_config = {
  :url => "redis://localhost:6379/0",
  :namespace => namespace
}

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
