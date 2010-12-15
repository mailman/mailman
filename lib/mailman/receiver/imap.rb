require 'net/imap'

module Mailman
  class Receiver
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
	      @processor, @username, @password, @server, @filter, @port = nil, nil, nil, nil, ["NEW"], 143

        @processor = options[:processor] if options.has_key? :processor
        @username =  options[:username]  if options.has_key? :username
        @password =  options[:password]  if options.has_key? :password
        @filter =    options[:filter]    if options.has_key? :filter
        @port =      options[:port]      if options.has_key? :port
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
      end

      # Iterates through new messages, passing them to the processor, and
      # deleting them.
      def get_messages
        @connection.search(@filter).each do  |message| 
          puts "PROCESSING MESSAGE #{message}"
          body=@connection.fetch(message,"RFC822")[0].attr["RFC822"]
          @processor.process(body)
	        @connection.store(message,"+FLAGS",[:Seen])
        end
        #@connection.delete_all
      end

    end
  end
end
