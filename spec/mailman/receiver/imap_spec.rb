require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper'))

describe Mailman::Receiver::IMAP do

  before do
    @processor = double('Message Processor', :process => true)
    @receiver_options = { :username  => 'user',
                          :password  => 'pass',
                          :server    =>  'example.com',
                          :processor => @processor }
    @receiver = Mailman::Receiver::IMAP.new(@receiver_options)
  end

  describe 'connection' do

    it 'should connect to a IMAP server' do
      @receiver.connect.should be_truthy
    end

    it 'should disconnect from a IMAP server' do
      @receiver.connect
      @receiver.disconnect.should be_truthy
    end

  end

  describe 'message reception' do
    before do
      @receiver.connect
    end

    it 'should get messages and process them' do
      @processor.should_receive(:process).twice.with(/test/)
      @receiver.get_messages
    end

    it 'should delete the messages after processing' do
      @receiver.get_messages
      @receiver.connection.search(:all).should be_empty
    end

  end

  describe 'started connection' do
    it 'should return the same of connection when started' do
      @receiver.connect
      expect_any_instance_of(MockIMAP).to receive(:disconnected?)
      @receiver.started?
    end
  end

end
