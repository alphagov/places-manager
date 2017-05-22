require "sidekiq"

redis_config = YAML.load(ERB.new(File.read("config/redis.yml")).result)[Rails.env].symbolize_keys

Sidekiq.configure_server do |config|
  config.redis = redis_config

  config.server_middleware do |chain|
    chain.add Sidekiq::Statsd::ServerMiddleware, env: 'govuk.app.imminence', prefix: 'workers'
  end
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
