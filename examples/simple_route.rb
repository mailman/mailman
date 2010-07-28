#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mailman'

Mailman::Application.run do

  from('%user%@%domain%') do
    puts "Got #{message.subject} from #{params[:user]}"
  end

end

# cat ../spec/fixtures/example01.eml | ./simple_route.rb
