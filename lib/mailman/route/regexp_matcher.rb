module Mailman
  class Route
    # Matches using a +Regexp+.
    class RegexpMatcher < Matcher

      # Matches against a string using the stored +Regexp+.
      # @param [String] string the string to match against
      # @return [({:captures => <String>}, <String>)] the params hash with
      #   +:captures+ set to an array of captures, and an array of captures.
      def match(string)
        if match = @pattern.match(string)
          captures = match.captures
          [{:captures => captures}, captures]
        end
      end

      def self.valid_pattern?(pattern)
        pattern.class == Regexp
      end

    end
  end
end
