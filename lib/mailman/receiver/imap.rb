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
      # @option options [Boolean,Hash] :ssl if options is true, then an attempt will
      #   be made to use SSL (now TLS) to connect to the server. A Hash can be used
      #   to enable ssl and supply SSL context options.
      # @option options [Boolean] :starttls use STARTTLS command to start
      #   TLS session.
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
        @ssl        = options[:ssl] || false
        @starttls   = options[:starttls] || false
        @port       = options[:port] || (@ssl ? 993 : 143)
        @folder     = options[:folder] || "INBOX"
        @move_seen   = options[:move_seen] || false
        @seen_folder     = options[:seen_folder] || "PROCESSED"

        if @starttls && @ssl
          raise StandardError.new("either specify ssl or starttls, not both")
        end
      end

      # Connects to the IMAP server.
      def connect
        tries ||= 5
        if @connection.nil? or @connection.disconnected?
          @connection = Net::IMAP.new(@server, port: @port, ssl: @ssl)
          if @starttls
            @connection.starttls
          end
          @connection.login(@username, @password)
        end
        @connection.select(@folder)
      rescue Net::IMAP::ByeResponseError, Net::IMAP::NoResponseError => e
        retry unless (tries -= 1).zero?
      end

      # Disconnects from the IMAP server.
      def disconnect
        return false if @connection.nil?
        @connection.logout
        @connection.disconnected? ? true : @connection.disconnect rescue nil
      end

      # Iterates through new messages, passing them to the processor, and
      # flagging them as done.
      def get_messages
        @connection.search(@filter).each do |message|
          body = @connection.fetch(message, "RFC822")[0].attr["RFC822"]
          begin
            @processor.process(body)
          rescue StandardError => error
            Mailman.logger.error "Error encountered processing message: #{message.inspect}\n #{error.class.to_s}: #{error.message}\n #{error.backtrace.join("\n")}"
            next
          end
          @connection.store(message, "+FLAGS", @done_flags)
          move message if @move_seen
        end
        # Clears messages that have the Deleted flag set
        @connection.expunge
      end

      def started?
        not (!@connection.nil? && @connection.disconnected?)
      end

      private

      #move the message from current folder to the destination folder
      #deleting it from the current folder
      def move message
        unless @connection.list('', @seen_folder)
          @connection.create(@seen_folder)
        end
        @connection.copy(message, @seen_folder)
        @connection.store(message, "+FLAGS", [Net::IMAP::DELETED])
      end
    end
  end
end
