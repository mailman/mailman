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

    # @return [String] the path to the rails root. Setting this to nil stops
    #   rails environment loading
    attr_accessor :rails_root

    # @return [boolean] whether or not to ignore stdin.  Setting this to true
    #   stops Mailman from entering stdin processing mode.
    attr_accessor :ignore_stdin

    # @return [boolean] catch SIGINT and allow current iteration to finish
    # rather than dropping dead immediately. Currently only works with POP3
    # connections.
    attr_accessor :graceful_death

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def poll_interval
      @poll_interval ||= 60
    end

    def rails_root
      @rails_root ||= '.'
    end

  end
end
