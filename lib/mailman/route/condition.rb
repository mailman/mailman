module Mailman
  class Route
    # The base condition class. All conditions should subclass and override
    # {#match}, and call {Condition.register} in the class body.
    class Condition

      # @return the matcher to match against.
      attr_reader :matcher

      # @param [String, Regexp] the raw matcher to use in the condition,
      #   converted to a matcher instance by {Matcher.create}
      def initialize(condition)
        @matcher = Matcher.create(condition)
      end

      # @abstract Extracts the attribute from the message, and runs the matcher
      #   on it.
      # @param message [Mail::Message] The message to match against
      # @return [(Hash, Array)] a hash to merge into params, and an array of
      #   block arguments.
      def match(message)
        raise NotImplementedError
      end

      # Registers a condition subclass, which creates instance methods on
      # {Route} and {Application}.
      # @param [Class] condition the condition subclass to register. The method
      #   name is extracted by taking the class name, such as +ToCondition+,
      #   and removing the +Condition+ ending
      def self.register(condition)
        condition_name = condition.to_s.split('::')[-1][0...-9].downcase
        Route.class_eval <<-EOM
          def #{condition_name}(pattern, &block)
            @conditions << #{condition}.new(pattern)
            if block_given?
              @block = block
            end
            self
          end
        EOM

        Application.class_eval <<-EOM
          def #{condition_name}(pattern, &block)
            @router.add_route Route.new.#{condition_name}(pattern, &block)
          end
        EOM
      end

    end
  end
end
