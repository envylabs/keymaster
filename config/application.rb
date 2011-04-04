require File.expand_path('../boot', __FILE__)
require 'rails/all'
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Keymaster
  class Application < Rails::Application
    config.encoding = 'utf-8'
    config.middleware.use 'Rack::ApiVersion'
  end
end
