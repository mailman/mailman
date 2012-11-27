module Mailman
  # The main application class. Pass a block to {#new} to create a new app.
  class Application

    def self.run(&block)
      app = new(&block)
      app.run
      app
    end

    # @return [Router] the app's router
    attr_reader :router

    # @return [MessageProcessor] the app's message processor
    attr_reader :processor

    # Creates a new router, and sets up any routes passed in the block.
    # @param [Hash] options the application options
    # @option options [true,false] :graceful_death catch interrupt signal and don't die until end of poll
    # @param [Proc] block a block with routes

    def initialize(&block)
      @router = Mailman::Router.new
      @processor = MessageProcessor.new(:router => @router)

      if Mailman.config.maildir
        require 'maildir'
        @maildir = Maildir.new(Mailman.config.maildir)
      end

      instance_eval(&block) if block_given?
    end

    def polling?
      Mailman.config.poll_interval > 0 && !@polling_interrupt
    end

    # Sets the block to run if no routes match a message.
    def default(&block)
      @router.default_block = block
    end

    # Runs the application.
    def run
      Mailman.logger.info "Mailman v#{Mailman::VERSION} started"

      rails_env = File.join(Mailman.config.rails_root, 'config', 'environment.rb')
      if Mailman.config.rails_root && File.exist?(rails_env) && !(defined?(Rails) && Rails.env)
        Mailman.logger.info "Rails root found in #{Mailman.config.rails_root}, requiring environment..."
        require rails_env
      end

      if Mailman.config.graceful_death
        # When user presses CTRL-C, finish processing current message before exiting
        Signal.trap("INT") { @polling_interrupt = true }
      end

      # STDIN
      if !Mailman.config.ignore_stdin && $stdin.fcntl(Fcntl::F_GETFL, 0) == 0
        Mailman.logger.debug "Processing message from STDIN."
        @processor.process($stdin.read)

      # IMAP
      elsif Mailman.config.imap
        options = {:processor => @processor}.merge(Mailman.config.imap)
        Mailman.logger.info "IMAP receiver enabled (#{options[:username]}@#{options[:server]})."
        polling_loop Receiver::IMAP.new(options)

      # POP3
      elsif Mailman.config.pop3
        options = {:processor => @processor}.merge(Mailman.config.pop3)
        Mailman.logger.info "POP3 receiver enabled (#{options[:username]}@#{options[:server]})."
        polling_loop Receiver::POP3.new(options)

      # Maildir
      elsif Mailman.config.maildir

        Mailman.logger.info "Maildir receiver enabled (#{Mailman.config.maildir})."

        process_maildir

        if Mailman.config.watch_maildir
          require 'listen'
          Mailman.logger.debug "Monitoring the Maildir for new messages..."

          callback = Proc.new do |modified, added, removed|
            process_maildir
          end

          @listener = Listen.to(File.join(Mailman.config.maildir, 'new')).change(&callback)
          @listener.start
        end
      end
    end

    # List all message in Maildir new directory and process it
    def process_maildir
      # Process messages queued in the new directory
      Mailman.logger.debug "Processing new message queue..."
      @maildir.list(:new).each do |message|
        @processor.process_maildir_message(message)
      end
    end

    private

    # Run the polling loop for the email inbox connection
    def polling_loop(connection)
      if polling?
        polling_msg = "Polling enabled. Checking every #{Mailman.config.poll_interval} seconds."
      else
        polling_msg = "Polling disabled. Checking for messages once."
      end
      Mailman.logger.info(polling_msg)

      loop do
        begin
          connection.connect
          connection.get_messages
          connection.disconnect
        rescue SystemCallError => e
          Mailman.logger.error e.message
        end

        break unless polling?
        sleep Mailman.config.poll_interval
      end
    end

  end
end
