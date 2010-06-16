require 'mail'
require 'active_support'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/hash/indifferent_access'

module Mailman

  [:Application, :Router, :Configuration, :Route, :Receiver, :MessageProcessor].each do |constant|
    autoload constant, "mailman/#{constant.to_s.underscore}"
  end

end
