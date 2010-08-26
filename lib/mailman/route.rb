module Mailman
  # The main route class. Has condition methods defined on it by
  # {Route::Condition.inherited}. Stores a route with a set of conditions and
  # matches against them.
  class Route

    # @return [Proc] the block that should be run if the conditions match
    attr_reader :block

    # @return [Class,String] the class (and optional instance method) to run
    #   instead of a block
    attr_reader :klass

    # @return [Array] the list of condition instances associated with the route
    attr_reader :conditions

    def initialize
      @conditions = []
    end

    # Checks whether a message matches the route.
    # @param [Mail::Message] message the message to match against
    # @return [Hash] the +:block+ and +:klass+ associated with the route, the
    #   +:params+ hash, and the block +:args+ array.
    def match!(message)
      params = {}
      args = []
      @conditions.each do |condition|
        if result = condition.match(message)
          params.merge!(result[0])
          args += result[1]
        else
          return nil
        end
      end
      { :block => @block, :klass => @klass, :params => params, :args => args }
    end

  end
end

require 'mailman/route/matcher'
require 'mailman/route/condition'
