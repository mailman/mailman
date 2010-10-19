require 'rack'
require 'rack/request'

module Mailman
  module Receiver
    
    # A Rack endpoint which passes incoming messages to a {MessageProcessor}.
    #
    # The endpoint expects the requests to contain a +message+ parameter, which
    # holds the encoded email.
    #
    # The endpoint returns status 200 if the message was accepted, and 400 if the
    # request was invalid.
    class Rack
      # @param [Hash] options the receiver options
      # @option options [MessageProcessor] :processor the processor to pass new
      #   messages to
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
