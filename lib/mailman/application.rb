module Mailman
  # The main application class. Pass a block to {#new} to create a new app.
  class Application

    # @return [Router] the app's router
    attr_reader :router

    # @return [MessageProcessor] the app's message processor
    attr_reader :processor

    # Creates a new router, and sets up any routes passed in the block.
    # @param [Proc] block a block with routes
    def initialize(&block)
      @router = Mailman::Router.new
      @processor = MessageProcessor.new(:router => @router)
      instance_eval(&block)
    end

    # Sets the block to run if no routes match a message.
    def default(&block)
      @router.default_block = block
    end

    # Runs the application.
    def run
      if $stdin.fcntl(Fcntl::F_GETFL, 0) == 0 # we have stdin
        @processor.process($stdin.read)
      elsif Configuration.pop3
        options = {:processor => @processor}.merge(Configuration.pop3)
        connection = Receiver::POP3.new(options)
        begin
          connection.connect
          if Configuration.poll_interval > 0 # we should poll
            loop do
              connection.get_messages
              sleep poll_interval
            end
          else # one-time retrieval
            connection.get_messages
          end
        ensure
          connection.disconnect
        end
      end
    end

  end
end
