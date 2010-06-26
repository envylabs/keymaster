ENV["RAILS_ENV"] = "test"
ENV["PUBLIC_SIGNING_KEY"] = File.read(File.join(File.dirname(__FILE__), 'public.key'))
ENV["PRIVATE_SIGNING_KEY"] = File.read(File.join(File.dirname(__FILE__), 'private.key'))
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end
