require 'mail'
require 'active_support'
require 'active_support/core_ext/string/inflections'

module Mailman

  [:Application, :Router, :Route, :Receiver, :MessageProcessor].each do |constant|
    autoload constant, "mailman/#{constant.to_s.underscore}"
  end

end
