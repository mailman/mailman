$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'fileutils'
require 'mailman'
require 'rspec'
require 'pop3_mock'
require 'maildir'

unless defined?(SPEC_ROOT)
  SPEC_ROOT = File.join(File.dirname(__FILE__))
end

module Mailman::SpecHelpers

  def regexp_matcher(pattern)
    Mailman::Route::RegexpMatcher.new(pattern)
  end

  def string_matcher(pattern)
    Mailman::Route::StringMatcher.new(pattern)
  end

  def basic_message
    Mail.new("To: test@example.com\r\nFrom: chunky@bacon.com\r\nCC: testing@example.com\r\nSubject: Hello!\r\n\r\nemail message\r\n")
  end

  def mailman_app(&block)
    @app = Mailman::Application.new(&block)
  end

  def send_message(message)
    @app.router.route Mail.new(message)
  end

  def config
    Mailman.config
  end

  def fixture(*name)
    File.open(File.join(SPEC_ROOT, 'fixtures', name) + '.eml').read
  end

  def setup_maildir
    maildir_path = File.join(SPEC_ROOT, 'test-maildir')
    FileUtils.rm_r(maildir_path) rescue nil
    @maildir = Maildir.new(maildir_path)
    message = File.new(File.join(maildir_path, 'new', 'message1'), 'w')
    message.puts(fixture('example01'))
    message.close
  end

end

RSpec.configure do |config|
  config.include Mailman::SpecHelpers
  config.before do
    Mailman.config.logger = Logger.new(File.join(SPEC_ROOT, 'mailman-log.log'))
  end
  config.after do
    FileUtils.rm File.join(SPEC_ROOT, 'mailman-log.log')
  end
end


class FakeSTDIN

  attr_accessor :string

  def initialize(string=nil)
    @string = string
  end

  def fcntl(*args)
    @string ? 0 : 2
  end

  def read
    @string
  end

end

$stdin = FakeSTDIN.new
