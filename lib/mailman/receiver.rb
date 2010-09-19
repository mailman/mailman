module Mailman
  module Receiver

    autoload :POP3, 'mailman/receiver/pop3'
    autoload :Rack, 'mailman/receiver/rack'

  end
end
