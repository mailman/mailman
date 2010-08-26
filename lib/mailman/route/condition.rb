module Mailman
  class Route
    # The base condition class. All conditions should subclass and override
    # {#match}.
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
      def self.inherited(condition)
        condition_name = condition.to_s.split('::')[-1][0...-9].downcase
        Route.class_eval <<-EOM
          def #{condition_name}(pattern, klass = nil, &block)
            @conditions << #{condition}.new(pattern)
            @klass = klass
            if block_given?
              @block = block
            end
            self
          end
        EOM

        Application.class_eval <<-EOM
          def #{condition_name}(pattern, klass = nil, &block)
            @router.add_route Route.new.#{condition_name}(pattern, klass, &block)
          end
        EOM
      end

    end
  end
end

require 'mailman/route/conditions'
