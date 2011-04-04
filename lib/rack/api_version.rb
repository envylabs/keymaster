module Rack
  class ApiVersion
    def initialize(app, version = Keymaster.version)
      @app = app
      @version = version
    end

    def call(env)
      @app.call(env).tap do |response|
        response[1]['X-API-Version'] = @version
      end
    end
  end
end
