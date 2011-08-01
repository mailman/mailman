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
      Mailman.logger.info "Mailman v#{Mailman::VERSION} started"

      rails_env = File.join(Mailman.config.rails_root, 'config', 'environment.rb')
      if Mailman.config.rails_root && File.exist?(rails_env)
        Mailman.logger.info "Rails root found in #{Mailman.config.rails_root}, requiring environment..."
        require rails_env
      end

      if !Mailman.config.ignore_stdin && $stdin.fcntl(Fcntl::F_GETFL, 0) == 0 # we have stdin
        Mailman.logger.debug "Processing message from STDIN."
        @processor.process($stdin.read)
      elsif Mailman.config.pop3
        options = {:processor => @processor}.merge(Mailman.config.pop3)
        Mailman.logger.info "POP3 receiver enabled (#{options[:username]}@#{options[:server]})."
        if Mailman.config.poll_interval > 0 # we should poll
          polling = true
          Mailman.logger.info "Polling enabled. Checking every #{Mailman.config.poll_interval} seconds."
        else
          polling = false
          Mailman.logger.info 'Polling disabled. Checking for messages once.'
        end

        connection = Receiver::POP3.new(options)
        loop do
          begin
            connection.connect
            connection.get_messages
            connection.disconnect
          rescue SystemCallError => e
            Mailman.logger.error e.message
          end

          break if !polling
          sleep Mailman.config.poll_interval
        end

      elsif Mailman.config.maildir
        require 'maildir'
        require 'fssm'

        Mailman.logger.info "Maildir receiver enabled (#{Mailman.config.maildir})."
        @maildir = Maildir.new(Mailman.config.maildir)

        Mailman.logger.debug "Monitoring the Maildir for new messages..."
        FSSM.monitor File.join(Mailman.config.maildir, 'new') do |monitor|
          monitor.create { |directory, filename| # a new message was delivered to new
            process_maildir
          }
        end
      end
    end

    ##
    # List all message in Maildir new directory and process it
    #
    def process_maildir
      # Process messages queued in the new directory
      Mailman.logger.debug "Processing new message queue..."
      @maildir.list(:new).each do |message|
        @processor.process_maildir_message(message)
      end
    end

  end
end
