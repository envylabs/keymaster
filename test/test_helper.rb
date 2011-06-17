ENV["RAILS_ENV"] = "test"
ENV["PUBLIC_SIGNING_KEY"] = File.read(File.expand_path('../public.key', __FILE__))
ENV["PRIVATE_SIGNING_KEY"] = File.read(File.expand_path('../private.key', __FILE__))

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

Dir[Rails.root.join("test/factories/**/*.rb")].each do |factory|
  require factory
end

class ActiveSupport::TestCase
  fixtures :all
end
