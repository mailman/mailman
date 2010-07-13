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
      elsif Mailman.config.pop3
        options = {:processor => @processor}.merge(Mailman.config.pop3)
        connection = Receiver::POP3.new(options)
        begin
          connection.connect
          if Mailman.config.poll_interval > 0 # we should poll
            loop do
              connection.get_messages
              sleep Mailman.config.poll_interval
            end
          else # one-time retrieval
            connection.get_messages
          end
        ensure
          connection.disconnect
        end
      elsif Mailman.config.maildir
        maildir = Maildir.new(Mailman.config.maildir)

        # Process messages queued in the new directory
        maildir.list(:new).each do |message|
          @processor.process_maildir_message(message)
        end

        FSSM.monitor File.join(Mailman.config.maildir, 'new') do |monitor|
          monitor.create { |directory, filename| # a new message was delivered to new
            message = Maildir::Message.new(maildir, "new/#{filename}")
            @processor.process_maildir_message(message)
          }
        end
      end
    end

  end
end
