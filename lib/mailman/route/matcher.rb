module Mailman
  class Route
    # The base matcher class. All matchers should subclass and override {#match}
    # and {Matcher.valid_pattern?}. Override {#compile!} if a pattern compiler is
    # needed.
    class Matcher

      # @return the matcher pattern, normally stored as a +Regexp+.
      attr_reader :pattern

      # Creates a new matcher and calls {#compile!}.
      # @param pattern the matcher pattern
      def initialize(pattern)
        @pattern = pattern
        compile!
      end

      # @abstract Matches a string against the stored pattern.
      # @param [String] string the string to match against
      # @return [(Hash, Array)] a hash to merge into params, and an array of
      #  arguments for the block.
      def match(string)
        raise NotImplementedError
      end

      # @abstract Compiles the pattern into something easier to work with, usually a
      #   +Regexp+.
      def compile!
      end

      class << self

        # @return [<Class>] The array of registered matchers.
        attr_reader :matchers

        # Registers a matcher so that it can be used in {Matcher.create}.
        # @param matcher [Class] a matcher subclass
        def inherited(matcher)
          @matchers ||= []
          @matchers << matcher
        end

        # Finds and creates a valid matcher instance for a given pattern.
        # @param pattern the pattern to create the matcher with
        def create(pattern)
          @matchers.each do |matcher|
            return matcher.new(pattern) if matcher.valid_pattern?(pattern)
          end
        end

        # @abstract Checks whether a pattern is valid.
        # @param pattern the pattern to check
        # @return [true, false]
        def valid_pattern?(pattern)
          raise NotImplementedError
        end

      end

    end
  end
end

require 'mailman/route/regexp_matcher'
require 'mailman/route/string_matcher'
