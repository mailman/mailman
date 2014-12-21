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
      # @option options [Integer] :port the port to connect to (default 110, or 995 for ssl)
      # @option options [String] :username the username to authenticate with
      # @option options [String] :password the password to authenticate with
      # @option options [true,false,Hash] :ssl enable SSL
      def initialize(options)
        @processor = options[:processor]
        @username = options[:username]
        @password = options[:password]
        port = options[:port] || (options[:ssl] ? 995 : 110)
        @connection = Net::POP3.new(options[:server], port)
        if options[:ssl].is_a? Hash
          @connection.enable_ssl(options[:ssl])
        elsif options[:ssl]
          @connection.enable_ssl
        end
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
          begin
            @processor.process(message.pop)
          rescue StandardError => error
            Mailman.logger.error "Error encountered processing message: #{message.inspect}\n #{error.class.to_s}: #{error.message}\n #{error.backtrace.join("\n")}"
            next
          end
        end
        @connection.delete_all
      end

      def started?
        @connection.started?
      end
    end
  end
end
