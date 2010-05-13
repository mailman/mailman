module Mailman
  class Receiver
    class POP3

      def initialize(options)
        @connection = options[:connection]
        @username = options[:username]
        @password = options[:password]
      end

      def connect
        @connection.start(@username, @password)
      end

      def disconnect
        @connection.finish
      end

    end
  end
end
