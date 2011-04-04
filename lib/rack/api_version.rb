module Rack
  class ApiVersion
    def initialize(app, options = {})
      @app = app
    end

    def call(env)
      @app.call(env).tap do |response|
        response[1]['X-API-Version'] = Keymaster.version
      end
    end
  end
end
