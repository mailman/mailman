require 'mailman'

module Mailman
  class CLI
    class ConfigNotDefined < StandardError; end

    def initialize(options = {})
      @config_file = options[:config_file]
      @pid_file = options[:pid_file]
      @environment = options[:environment]
    end

    def run
      set_environment
      record_pid_file
      load_config
    end

    def set_environment
      ENV['RACK_ENV'] = ENV['RAILS_ENV'] = @environment
    end

    def load_config
      if @config_file
        require @config_file
      else
        raise ConfigNotDefined.new
      end
    end

    def record_pid_file
      if @pid_file
        File.open(@pid_file, 'w') do |f|
          f.puts Process.pid
        end
      end
    end
  end
end
