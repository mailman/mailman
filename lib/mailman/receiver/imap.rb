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
      # @option options [Boolean] :ssl whether or not to use ssl
      # @option options [String] :username the username to authenticate with
      # @option options [String] :password the password to authenticate with
      # @option options [String] :folder the mail folder to search
      # @option options [Array] :done_flags the flags to add to messages that
      #   have been processed
      # @option options [String] :filter the search filter to use to select
      #   messages to process
      def initialize(options)
        @processor  = options[:processor]
        @server     = options[:server]
        @username   = options[:username]
        @password   = options[:password]
        @filter     = options[:filter] || 'UNSEEN'
        @done_flags = options[:done_flags] || [Net::IMAP::SEEN]
        @port       = options[:port] || 143
        @ssl        = options[:ssl] || false
        @folder     = options[:folder] || "INBOX"
      end

      # Connects to the IMAP server.
      def connect
        if @connection.nil? or @connection.disconnected?
          @connection = Net::IMAP.new(@server, port: @port, ssl: @ssl)
          @connection.login(@username, @password)
        end
        @connection.select(@folder)
      end

      # Disconnects from the IMAP server.
      def disconnect
        @connection.logout
        @connection.disconnected? ? true : @connection.disconnect rescue nil
      end

      # Iterates through new messages, passing them to the processor, and
      # flagging them as done.
      def get_messages
        @connection.search(@filter).each do |message|
          body = @connection.fetch(message, "RFC822")[0].attr["RFC822"]
          @processor.process(body)
          @connection.store(message, "+FLAGS", @done_flags)
        end
        # Clears messages that have the Deleted flag set
        @connection.expunge
      end

    end
  end
end
