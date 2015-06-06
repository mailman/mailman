module Mailman
  class Route
    # Matches Hashes against the headers of a +Mail::Message+.
    class HeaderMatcher < Matcher

      # Matches against a hash using the given stored +Regexp+.
      # @param [Mail::Header] headers the message headers
      # @return [({:captures => <String>}, <String>)] the params hash with
      #   +:captures+ set to an array of captures, and an array of captures.
      def match(headers)
        all_captures = [{:captures => {}}, []]
        required_matches = @pattern.keys
        headers.fields.each do |header|
          header_symbol = header.name.underscore.to_sym
          value_matcher = @pattern[header_symbol]
          next if value_matcher.nil?
          captures = value_matcher.match(header.value)
          if !value_matcher.nil? && !captures.nil?
            required_matches -= [header_symbol]
            (all_captures[0][:captures][header_symbol] ||= []).push(captures[0][:captures])
            all_captures[1].push(*captures[1])
          end
        end
        required_matches.empty? ? all_captures : nil
      end

      # convert the keys into symbols and the values into matchers in their own right
      def compile!
        pre_compiled = @pattern
        @pattern = {}
        pre_compiled.each do |k, v|
          @pattern[k.to_sym] = Matcher.create(v)
        end
      end

      def self.valid_pattern?(pattern)
        pattern.is_a? Hash
      end
    end
  end
end
