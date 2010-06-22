module Mailman
  class Route

    # Matches against the To addresses of a message.
    class ToCondition < Condition
      def match(message)
        message.to.each do |address|
          if result = @matcher.match(address)
            return result
          end
        end
        nil
      end
    end

    # Matches against the From addresses of a message.
    class FromCondition < Condition
      def match(message)
        message.from.each do |address|
          if result = @matcher.match(address)
            return result
          end
        end
        nil
      end
    end

    # Matches against the Subject of a message.
    class SubjectCondition < Condition
      def match(message)
        @matcher.match(message.subject)
      end
    end

    # Matches against the Body of a message.
    class BodyCondition < Condition
      def match(message)
        @matcher.match(message.body.decoded)
      end
    end

  end
end
