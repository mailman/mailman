module Mailman
  class Route

    class ToCondition < Condition
      def match(message)
        message.to.each do |address|
          if result = @matcher.match(address)
            return result
          end
        end
        nil
      end

      Condition.register self
    end

    class FromCondition < Condition
      def match(message)
        message.from.each do |address|
          if result = @matcher.match(address)
            return result
          end
        end
        nil
      end

      Condition.register self
    end

    class SubjectCondition < Condition
      def match(message)
        @matcher.match(message.subject)
      end

      Condition.register self
    end

    class BodyCondition < Condition
      def match(message)
        @matcher.match(message.body.decoded)
      end

      Condition.register self
    end

  end
end
