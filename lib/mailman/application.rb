module Mailman
  # The main application class. Pass a block to {#new} to create a new app.
  class Application

    def self.run(config=nil, &block)
      if config
        app = new(config, &block)
      else
        app = new(&block)
      end
      app.run
      app
    end

    # @return [Router] the app's router
    attr_reader :router

    # @return [MessageProcessor] the app's message processor
    attr_reader :processor

    # @return [Config] the apps's configuration
    attr_reader :config

    # Creates a new router, and sets up any routes passed in the block.
    # @param [Hash] options the application options
    # @option options [true,false] :graceful_death catch interrupt signal and don't die until end of poll
    # @param [Proc] block a block with routes

    def initialize(config=:default, &block)
      @router = Mailman::Router.new
      @config = select_config(config)
      @processor = MessageProcessor.new(:router => @router, :config => @config)

      if self.config.maildir
        require 'maildir'
        @maildir = Maildir.new(self.config.maildir)
      end

      instance_eval(&block) if block_given?
    end

    def polling?
      config.poll_interval > 0 && !@polling_interrupt
    end

    # Sets the block to run if no routes match a message.
    def default(&block)
      @router.default_block = block
    end

    # Runs the application.
    def run
      Mailman.logger.info "Mailman v#{Mailman::VERSION} started"

      if config.rails_root
        rails_env = File.join(config.rails_root, 'config', 'environment.rb')
        if File.exist?(rails_env) && !(defined?(Rails) && Rails.env)
          Mailman.logger.info "Rails root found in #{config.rails_root}, requiring environment..."
          require rails_env
        end
      end

      if config.graceful_death
        # When user presses CTRL-C, finish processing current message before exiting
        Signal.trap("INT") { @polling_interrupt = true }
      end

      # STDIN
      if !config.ignore_stdin && $stdin.fcntl(Fcntl::F_GETFL, 0) == 0
        Mailman.logger.debug "Processing message from STDIN."
        @processor.process($stdin.read)

      # IMAP
      elsif config.imap
        options = {:processor => @processor}.merge(config.imap)
        Mailman.logger.info "IMAP receiver enabled (#{options[:username]}@#{options[:server]})."
        polling_loop Receiver::IMAP.new(options)

      # POP3
      elsif config.pop3
        options = {:processor => @processor}.merge(config.pop3)
        Mailman.logger.info "POP3 receiver enabled (#{options[:username]}@#{options[:server]})."
        polling_loop Receiver::POP3.new(options)

      # Maildir
      elsif config.maildir

        Mailman.logger.info "Maildir receiver enabled (#{config.maildir})."

        Mailman.logger.debug "Processing new message queue..."
        @maildir.list(:new).each do |message|
          @processor.process_maildir_message(message)
        end

        if config.watch_maildir
          require 'listen'
          Mailman.logger.debug "Monitoring the Maildir for new messages..."

          callback = Proc.new do |modified, added, removed|
            added.each do |new_file|
              message = Maildir::Message.new(@maildir, "new/#{new_file}")
              @processor.process_maildir_message(message)
            end
          end

          @listener = Listen.to(File.join(@maildir.path, 'new'), :relative_paths => true).change(&callback)
          @listener.start
        end
      end
    end

    private

    def select_config(new_config)
      return Mailman.config if new_config == :default
      return new_config if new_config.is_a?(Configuration)
      return Configuration.from_hash(new_config) if new_config.is_a?(Hash)
      return Configuration.new
    end

    # Run the polling loop for the email inbox connection
    def polling_loop(connection)
      if polling?
        polling_msg = "Polling enabled. Checking every #{config.poll_interval} seconds."
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
        sleep config.poll_interval
      end
    end

  end
end
