module Mailman
  class Configuration

    # Takes a block that is evaluated in the singleton to set options.
    def initialize(&block)
      class_eval(&block)
    end

    class << self

      # @return [Logger] the application's logger
      attr_accessor :logger

      def logger
        @logger ||= Logger.new(STDOUT)
      end

    end

  end
end
