ENV["RAILS_ENV"] = "test"
ENV["PUBLIC_SIGNING_KEY"] = File.read(File.join(File.dirname(__FILE__), 'public.key'))
ENV["PRIVATE_SIGNING_KEY"] = File.read(File.join(File.dirname(__FILE__), 'private.key'))

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

Dir[Rails.root.join("test/factories/**/*.rb")].each do |factory|
  require factory
end

class ActiveSupport::TestCase
  fixtures :all
end
