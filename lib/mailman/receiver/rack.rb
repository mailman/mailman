require 'rack'
require 'rack/request'

module Mailman
  module Receiver
    
    class Rack
      def initialize(options = {})
        @processor = options[:processor]
      end

      def call(env)
        request = ::Rack::Request.new(env)

        message = request.params["message"]

        return bad_request if message.nil?

        @processor.process(message)

        return ok
      end

      protected

      def bad_request
        [400, {"Content-Type" => "text/plain"}, "Bad Request"]
      end

      def ok
        [200, {"Content-Type" => "text/plain"}, "OK"]
      end
    end

  end
end
