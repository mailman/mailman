require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe Mailman::Configuration do

  # in spec_helper config = Mailman::Configuration

  describe 'logger' do

    before do
      @original_logger = config.logger
    end

    after do
      config.logger = @original_logger
    end

    it 'should have a default logger' do
      config.logger = nil
      config.logger.instance_variable_get('@logdev').dev.should == STDOUT
    end

    it 'should store a custom logger' do
      config.logger = Logger.new(STDERR)
      config.logger.instance_variable_get('@logdev').dev.should == STDERR
    end

  end

  it 'should store the POP3 config hash' do
    config.pop3 = {:user => 'foo'}
    config.pop3.should == {:user => 'foo'}
    config.pop3 = nil
  end

  it 'should have a default poll interval' do
    config.poll_interval = nil
    config.poll_interval.should == 60
  end

  it 'should store the poll interval' do
    config.poll_interval = 20
    config.poll_interval.should == 20
    config.poll_interval = nil
  end

end
