$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mailman'
require 'spec'
require 'spec/autorun'

module Mailman::SpecHelpers
  def regexp_matcher(pattern)
    Mailman::Route::RegexpMatcher.new(pattern)
  end

  def string_matcher(pattern)
    Mailman::Route::StringMatcher.new(pattern)
  end

  def basic_message
    Mail.new("To: test@example.com\r\nFrom: chunky@bacon.com\r\nSubject: Hello!\r\n\r\nemail message\r\n")
  end
end

Spec::Runner.configure do |config|
  config.include Mailman::SpecHelpers
end

