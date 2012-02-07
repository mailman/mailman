require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe Mailman::Configuration do

  # in spec_helper config = Mailman.config

  after do
    Mailman.reset_config!
  end

  it 'should have a default logger' do
    config.logger = nil
    config.logger.instance_variable_get('@logdev').dev.should == STDOUT
  end

  it 'should store a custom logger' do
    config.logger = Logger.new(STDERR)
    config.logger.instance_variable_get('@logdev').dev.should == STDERR
  end

  it 'should store the POP3 config hash' do
    config.pop3 = {:user => 'foo'}
    config.pop3.should == {:user => 'foo'}
  end

  it 'should have a default poll interval' do
    config.poll_interval = nil
    config.poll_interval.should == 60
  end

  it 'should store the poll interval' do
    config.poll_interval = 20
    config.poll_interval.should == 20
  end

  it 'should store the maildir location' do
    config.maildir = '../maildir-test'
    config.maildir.should == '../maildir-test'
  end

  it 'should have a default rails root' do
    config.rails_root.should == '.'
  end

  it 'should store a custom rails root' do
    config.rails_root = 'test-app'
    config.rails_root.should == 'test-app'
  end
  
  it 'should default to not ignoring stdin' do
    config.ignore_stdin.should == nil
  end
  
  it 'should store ignore_stdin setting' do
    config.ignore_stdin = true
    config.ignore_stdin.should == true
  end

  it "should store graceful_death flag" do
    config.graceful_death = true
    config.graceful_death.should == true
  end
end
