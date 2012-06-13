module Mailman
  # The router. Stores routes and uses them to process messages.
  class Router

    # @return [Array] the list of routes
    attr_accessor :routes

    # @return [Proc] the block to run if a message has bounced
    attr_accessor :bounce_block

    # @return [Proc] the block to run if no routes match
    attr_accessor :default_block

    # @return [Hash] the params of the most recently processed message. Used by
    #   route blocks
    attr_reader :params

    # @return [Mail::Message] the most recently processed message
    attr_reader :message

    def initialize
      @routes = []
      @params = HashWithIndifferentAccess.new
    end

    # Adds a route to the router.
    # @param [Mailman::Route] the route to add.
    # @return [Mailman::Route] the route object that was added (allows
    #   chaining).
    def add_route(route)
      @routes.push(route)[-1]
    end

    # Route a message. If the route block accepts arguments, it passes any
    # captured params. Named params are available from the +params+ helper. The
    # message is available from the +message+ helper.
    # @param [Mail::Message] the message to route.
    def route(message)
      @params.clear
      @message = message
      result = nil

      if @bounce_block and message.respond_to?(:bounced?) and message.bounced?
        return instance_exec(&@bounce_block)
      end

      routes.each do |route|
        break if result = route.match!(message)
      end

      if result
        @params.merge!(result[:params])
        if !result[:klass].nil?
          if result[:klass].is_a?(Class) # no instance method specified
            result[:klass].new.send(:receive, @message, @params)
          elsif result[:klass].kind_of?(String) # instance method specified
            klass, method = result[:klass].split('#')
            klass.camelize.constantize.new.send(method.to_sym, @message, @params)
          end
        elsif result[:block].arity > 0
          instance_exec(*result[:args], &result[:block])
        else
          instance_exec(&result[:block])
        end
      elsif @default_block
        instance_exec(&@default_block)
      end
    end

  end
end
