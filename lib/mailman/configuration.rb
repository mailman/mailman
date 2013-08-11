module Mailman
  class Configuration

    # @return [Logger] the application's logger
    attr_accessor :logger

    # @return [Hash] the configuration hash for POP3
    attr_accessor :pop3, :imap

    # @return [Fixnum] the poll interval for POP3 or IMAP. Setting this to 0
    #   disables polling
    attr_accessor :poll_interval

    # @return [String] the path to the maildir
    attr_accessor :maildir

    # @return [boolean] whether or not to watch for new messages in the maildir.
    #   Settings this to false disables listening for file changes if using the Maildir receiver.
    attr_accessor :watch_maildir

    # @return [String] the path to the rails root. Setting this to false to stop
    #   the rails environment from loading
    attr_accessor :rails_root

    # @return [boolean] whether or not to ignore stdin.  Setting this to true
    #   stops Mailman from entering stdin processing mode.
    attr_accessor :ignore_stdin

    # @return [boolean] catch SIGINT and allow current iteration to finish
    # rather than dropping dead immediately. Currently only works with POP3
    # connections.
    attr_accessor :graceful_death

    def middleware
      @middleware ||= Mailman::Middleware.new
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def poll_interval
      @poll_interval ||= 60
    end

    def watch_maildir
      @watch_maildir.nil? ? true : @watch_maildir
    end

    def rails_root
      @rails_root.nil? ? '.' : @rails_root
    end

    def self.from_hash(options)
      config = self.new
      options.each do |key, value|
        config.send "#{key}=", value
      end
      config
    end

  end
end
