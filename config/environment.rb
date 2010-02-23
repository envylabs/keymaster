RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem        'friendly_id', :version => '=2.3.2'

  config.time_zone  = 'UTC'
  
  config.middleware.use 'RsaResponseSigning', ENV['PRIVATE_SIGNING_KEY']
  
end
