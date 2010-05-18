module Mailman
  class Receiver
    # Receives messages using POP3, and passes them to a {MessageProcessor}.
    class POP3

      # @param [Hash] options the receiver options
      # @option options [MessageProcessor] :processor the processor to pass new
      #   messages to
      # @option options [Net::POP3] :connection the connection to use
      # @option options [String] :username the username to authenticate with
      # @option options [String] :password the password to authenticate with
      def initialize(options)
        @processor = options[:processor]
        @connection = options[:connection]
        @username = options[:username]
        @password = options[:password]
      end

      # Connects to the POP3 server.
      def connect
        @connection.start(@username, @password)
      end

      # Disconnects from the POP3 server.
      def disconnect
        @connection.finish
      end

      # Iterates through new messages, passing them to the processor, and
      # deleting them.
      def get_messages
        @connection.each_mail do |message|
          @processor.process(message.pop)
          message.delete
        end
      end

    end
  end
end
