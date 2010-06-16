module Mailman
  class Configuration

    class << self

      # @return [Logger] the application's logger
      attr_accessor :logger

      def logger
        @logger ||= Logger.new(STDOUT)
      end

    end

  end
end
