require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Keymaster
  class Application < Rails::Application
    config.encoding = 'utf-8'
    config.middleware.use 'Rack::ApiVersion'

    config.assets.enabled = true
    config.assets.version = '1.0'
  end
end
