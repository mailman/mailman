require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe Mailman::Configuration do

  it 'should have a default logger' do
    Mailman::Configuration.logger.instance_variable_get('@logdev').dev.should == STDOUT
  end

  it 'should store a custom logger using the class method' do
    Mailman::Configuration.logger = Logger.new(STDERR)
    Mailman::Configuration.logger.instance_variable_get('@logdev').dev.should == STDERR
  end

end
