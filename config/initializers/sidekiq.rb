# sidekiq

REDIS_SETTINGS = { url: ENV.fetch('REDIS_URL'), ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }.freeze

Sidekiq.configure_server do |config|
  config.redis = REDIS_SETTINGS
end

Sidekiq.configure_client do |config|
  config.redis = REDIS_SETTINGS
end
