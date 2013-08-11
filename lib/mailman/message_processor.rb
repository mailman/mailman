module Mailman
  # Turns a raw email into a +Mail::Message+ and passes it to the router.
  class MessageProcessor

    # @param [Hash] options the options to create the processor with
    # @option options [Router] :router the router to pass processed
    #   messages to
    def initialize(options)
      @router = options[:router]
      @config = options[:config]
    end

    # Converts a raw email into a +Mail::Message+ instance, and passes it to the
    # router.
    # @param [String] message the message to process
    def process(message)
      mail = Mail.new(message)
      from = mail.from.nil? ? "unknown" : mail.from.first
      Mailman.logger.info "Got new message from '#{from}' with subject '#{mail.subject}'."

      # Run any middlewares before routing the message
      @config.middleware.run(mail) do
        @router.route(mail)
      end
    end

    # Processes a +Maildir::Message+ instance.
    def process_maildir_message(message)
      begin
        process(message.data)
        message.process # move message to cur
        message.seen!
      rescue StandardError => error
        Mailman.logger.error "Error encountered processing message: #{message.inspect}\n #{error.class.to_s}: #{error.message}\n #{error.backtrace.join("\n")}"
      end
    end

  end
end
