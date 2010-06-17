module Mailman
  # The main application class. Pass a block to {#new} to create a new app.
  class Application

    # @return [Router] the app's router
    attr_reader :router

    # Creates a new router, and sets up any routes passed in the block.
    # @param [Proc] block a block with routes
    def initialize(&block)
      @router = Mailman::Router.new
      instance_eval(&block)
    end

    # Sets the block to run if no routes match a message.
    def default(&block)
      @router.default_block = block
    end

    # Runs the application.
    def run
      if $stdin.fcntl(Fcntl::F_GETFL, 0) == 0 # we have stdin
        MessageProcessor.new(:router => @router).process($stdin.read)
      end
    end

  end
end
