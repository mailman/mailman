require 'net/imap'

module Mailman
  module Receiver
    # Receives messages using IMAP, and passes them to a {MessageProcessor}.
    class IMAP

      # @return [Net::IMAP] the IMAP connection
      attr_reader :connection

      # @param [Hash] options the receiver options
      # @option options [MessageProcessor] :processor the processor to pass new
      #   messages to
      # @option options [String] :server the server to connect to
      # @option options [Integer] :port the port to connect to
      # @option options [String] :username the username to authenticate with
      # @option options [String] :password the password to authenticate with
      def initialize(options)
        @processor = options[:processor]
        @username  = options[:username]
        @password  = options[:password]
        @filter    = options[:filter] || ['NEW']
        @port      = options[:port] || 143

        @connection = Net::IMAP.new(options[:server], @port)
      end

      # Connects to the IMAP server.
      def connect
        @connection.login(@username, @password)
        @connection.examine("INBOX")
      end

      # Disconnects from the IMAP server.
      def disconnect
        @connection.logout
        @connection.disconnected? ? true : @connection.disconnect rescue nil
      end

      # Iterates through new messages, passing them to the processor, and
      # deleting them.
      def get_messages
        @connection.search(@filter).each do  |message|
          body = @connection.fetch(message,"RFC822")[0].attr["RFC822"]
          @processor.process(body)
          @connection.store(message,"+FLAGS",[Net::IMAP::DELETED])
        end
        # Clears messages that have the Deleted flag set
        @connection.expunge
      end

    end
  end
end
