module Mailman
  class Route
    class RegexpMatcher < Matcher

      def match(string)
        if match = @pattern.match(string)
          captures = match.captures
          [{:captures => captures}, captures]
        end
      end

    end
  end
end
