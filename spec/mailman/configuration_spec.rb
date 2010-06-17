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

    it 'should store a custom logger using the class method' do
      config.logger = Logger.new(STDERR)
      config.logger.instance_variable_get('@logdev').dev.should == STDERR
    end

  end

end
