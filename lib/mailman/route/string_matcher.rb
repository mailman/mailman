module Mailman
  class Route
    # Matches using a +String+ with named param captures formatted like
    # +%user%@example.com+.
    class StringMatcher < Matcher

      # @return [Array<Symbol>] the names of the param captures
      attr_reader :keys

      # Matches against a string using the stored pattern.
      # @param [String] string the string to match against
      # @return [({Symbol => String}, <String>)] the params hash, and array of
      #   captures.
      def match(string)
        params = {}
        if match = @pattern.match(string)
          captures = match.captures
          params.merge!(Hash[*@keys.zip(captures).flatten])
          [params, captures]
        end
      end

      def compile!
        @keys = []
        special_chars = %w/* . + ? \\ | ^ $ ( ) [ ] { } /
        compiled_pattern = @pattern.to_s.gsub(/((%[A-Za-z_]+%)|[\*\\.+?|^$()\[\]{}])/) do |match|
          case match
          when *special_chars
            Regexp.escape(match)
          else
            @keys << $2[1..-2].to_sym
            '(.*)'
          end
        end
        @pattern = /#{compiled_pattern}/i
      end

      def self.valid_pattern?(pattern)
        pattern.respond_to?(:to_s)
      end

    end
  end
end
