module Mailman
  class Route
    class RegexpMatcher < Matcher

      def match(string)
        if match = @pattern.match(string)
          captures = match.captures
          [{:captures => captures}, captures]
        end
      end

      def self.valid_pattern?(pattern)
        pattern.class == Regexp
      end

      Matcher.register self

    end
  end
end
