module Mailman
  class Route
    # @abstract The base matcher class. All matchers should subclass and
    #   override {#match} to implement this API. A pattern compiler method may
    #   be required.
    class Matcher

      ##
      # Creates a new matcher instance.
      #
      # @param pattern the matcher pattern.
      def initialize(pattern)
        @pattern = pattern
      end

      ##
      # Matches a string against the stored pattern.
      #
      # @param [String, #to_s] string the string to match against
      # @return [Array(Hash, Array)] a hash to merge into params, and an array
      #   of arguments for the block
      def match(string)
        raise NotImplementedError
      end

    end
  end
end
