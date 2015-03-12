require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe Mailman::Configuration do

  # in spec_helper config = Mailman.config

  after do
    Mailman.reset_config!
  end

  it 'should have a default logger' do
    config.logger = nil
    expect(config.logger.instance_variable_get('@logdev').dev).to eq(STDOUT)
  end

  it 'should store a custom logger' do
    config.logger = Logger.new(STDERR)
    expect(config.logger.instance_variable_get('@logdev').dev).to eq(STDERR)
  end

  it 'should store the POP3 config hash' do
    config.pop3 = {:user => 'foo'}
    expect(config.pop3).to eq({:user => 'foo'})
  end

  it 'should have a default poll interval' do
    config.poll_interval = nil
    expect(config.poll_interval).to eq(60)
  end

  it 'should store the poll interval' do
    config.poll_interval = 20
    expect(config.poll_interval).to eq(20)
  end

  it 'should store the maildir location' do
    config.maildir = '../maildir-test'
    expect(config.maildir).to eq('../maildir-test')
  end

  it 'should have a defaut watch maildir setting' do
    expect(config.watch_maildir).to eq(true)
  end

  it 'should store the maildir listen setting' do
    config.watch_maildir = false
    expect(config.watch_maildir).to eq(false)
  end

  it 'should have a default rails root' do
    expect(config.rails_root).to eq('.')
  end

  it 'should store a custom rails root' do
    config.rails_root = 'test-app'
    expect(config.rails_root).to eq('test-app')
  end
  
  it 'should default to not ignoring stdin' do
    expect(config.ignore_stdin).to eq(nil)
  end
  
  it 'should store ignore_stdin setting' do
    config.ignore_stdin = true
    expect(config.ignore_stdin).to eq(true)
  end

  it "should store graceful_death flag" do
    config.graceful_death = true
    expect(config.graceful_death).to eq(true)
  end
end
