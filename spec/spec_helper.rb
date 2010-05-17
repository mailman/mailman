$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mailman'
require 'spec'
require 'spec/autorun'

module Mailman::SpecHelpers
  def regexp_matcher(pattern)
    Mailman::Route::RegexpMatcher.new(pattern)
  end
end

Spec::Runner.configure do |config|
  config.include Mailman::SpecHelpers
end

