Keymaster::Application.config.middleware.use 'Rack::ResponseSignature', ENV['PRIVATE_SIGNING_KEY'] if Rails.env.production?
