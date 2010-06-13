module Mailman

end

require 'mail'

require 'mailman/router'
require 'mailman/application'
require 'mailman/receiver'
require 'mailman/receiver/pop3'
require 'mailman/message_processor'
require 'mailman/route'
require 'mailman/route/matcher'
require 'mailman/route/regexp_matcher'
require 'mailman/route/string_matcher'
require 'mailman/route/condition'
require 'mailman/route/conditions'
