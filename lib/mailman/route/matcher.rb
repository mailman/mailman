module Mailman
  class Route

    ##
    # @abstract The base matcher class. All matchers should subclass and
    #   override {#match} to implement this API. Override {#compile!} if a
    #   pattern compiler is needed.
    class Matcher

      attr_reader :pattern

      ##
      # Creates a new matcher instance.
      #
      # @param pattern the matcher pattern.
      def initialize(pattern)
        @pattern = pattern
        compile!
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

      ##
      # Compiles the pattern into something easier to work with, usually a
      # Regexp.
      def compile!
      end

    end
  end
end
