require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper'))

describe Mailman::Receiver::POP3 do

  before do
    @processor = mock('Message Processor', :process => true)
    @connection = MockPOP3.new
    @receiver_options = { :username => 'user',
                          :password => 'pass',
                          :connection => @connection,
                          :processor => @processor }
    @receiver = Mailman::Receiver::POP3.new(@receiver_options)
  end

  describe 'connection' do

    it 'should connect to a POP3 server' do
      @receiver.connect.should be_true
    end

    it 'should disconnect from a POP3 server' do
      @receiver.connect
      @receiver.disconnect.should be_true
    end

  end

  describe 'message reception' do
    before do
      @receiver.connect
    end

    it 'should get messages and process them' do
      @processor.should_receive(:process).twice.with('Email Message')
      @receiver.get_messages
    end

    it 'should delete the messages after processing' do
      @receiver.get_messages
      @connection.messages.should be_empty
    end

  end

end

class MockPOP3

  attr_accessor :messages

  def initialize
    @messages = [MockPOPMail.new(self), MockPOPMail.new(self)]
    @deleted_messages = 0
  end

  def start(account, password)
    return self if account == 'user' && password == 'pass'
  end

  def finish
    true
  end

  def each_mail(&block)
    @messages.each { |m| yield m }
    @deleted_messages.times { @messages.pop } # simulate message deletion
    @deleted_messages = 0
  end

  def delete_message
    @deleted_messages += 1
  end

end

class MockPOPMail

  def initialize(connection)
    @connection = connection
  end

  def pop
    'Email Message'
  end

  def delete
    @connection.delete_message
  end

end
