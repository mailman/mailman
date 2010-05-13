module Mailman
  class Receiver
    class POP3

      def initialize(options)
        @processor = options[:processor]
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

      def get_messages
        @connection.each_mail do |message|
          @processor.process(message.pop)
        end
      end

    end
  end
end
