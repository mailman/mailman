require 'net/pop'

module Mailman
  module Receiver
    # Receives messages using POP3, and passes them to a {MessageProcessor}.
    class POP3

      # @return [Net::POP3] the POP3 connection
      attr_reader :connection

      # @param [Hash] options the receiver options
      # @option options [MessageProcessor] :processor the processor to pass new
      #   messages to
      # @option options [String] :server the server to connect to
      # @option options [Integer] :port the port to connect to
      # @option options [String] :username the username to authenticate with
      # @option options [String] :password the password to authenticate with
      # @option options [true,false] :ssl enable SSL
      def initialize(options)
        @processor = options[:processor]
        @username = options[:username]
        @password = options[:password]
        @connection = Net::POP3.new(options[:server], options[:port])
        @connection.enable_ssl(OpenSSL::SSL::VERIFY_NONE) if options[:ssl]
        @connection.open_timeout = options[:open_timeout] if options[:open_timeout]
        @connection.read_timeout = options[:read_timeout] if options[:read_timeout]
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
        end
        @connection.delete_all
      end

    end
  end
end
