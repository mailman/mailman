module Mailman

end

require 'mail'

require 'mailman/receiver'
require 'mailman/receiver/pop3'
require 'mailman/message_processor'
require 'mailman/route'
require 'mailman/route/matcher'
require 'mailman/route/regexp_matcher'
