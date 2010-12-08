if Rails.env.production?
  require 'lib/rack/response-signature-repeater'
  Keymaster::Application.config.middleware.use 'Rack::ResponseSignatureRepeater'
  Keymaster::Application.config.middleware.use 'Rack::ResponseSignature', ENV['PRIVATE_SIGNING_KEY']
end
