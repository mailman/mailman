module Mailman
  # The main application class. Pass a block to {#new} to create a new app.
  class Application

    # @return [Router] the app's router
    attr_reader :router

    # @return [HashWithIndifferentAccess] a hash of config options
    attr_accessor :config

    # Creates a new router, and sets up any routes passed in the block.
    # @param [Proc] block a block with routes
    def initialize(&block)
      @config = HashWithIndifferentAccess.new
      @router = Mailman::Router.new
      instance_eval(&block)
    end

    # Sets the block to run if no routes match a message.
    def default(&block)
      @router.default_block = block
    end

    # Sets a config option.
    # @param [Symbol] key the config key
    # @param value the config value
    def set(key, value)
      @config[key] = value
    end

  end
end
