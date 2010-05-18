module Mailman
  class Route
    class Condition

      attr_reader :matcher

      def initialize(condition)
        @matcher = Matcher.create(condition)
      end

      ##
      # @abstract Extracts the attribute from the message, and runs the matcher
      #   on it.
      #
      # @param message [Mail::Message] The message to match against
      # @return [Array(Hash, Array)] a hash to merge into params, and an array
      #   of block arguments
      def match(message)
        raise NotImplementedError
      end

      def self.register(condition)
        condition_name = condition.to_s.split('::')[-1][0...-9].downcase
        Route.class_eval <<-EOM
          def #{condition_name}(pattern, &block)
            @conditions << #{condition}.new(pattern)
            if block_given?
              @block = block
              true
            else
              self
            end
          end
        EOM
      end

    end
  end
end
