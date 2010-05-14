module Mailman
  class MessageProcessor

    def initialize(options)
      @router = options[:router]
    end

    def process(message)
      @router.route(Mail.new(message))
    end

  end
end
