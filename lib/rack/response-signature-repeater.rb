module Rack
  class ResponseSignatureRepeater
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, response = @app.call(env)
      headers['Response-Signature'] ||= headers['X-Response-Signature']
      [status, headers, response]
    end
  end
end
