require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper'))

describe Mailman::Receiver::POP3 do
  before do
    @processor = double('Message Processor', process: true)
    @receiver_options = { username: 'user',
                          password: 'pass',
                          server: 'example.com',
                          processor: @processor,
                          open_timeout: 30,
                          read_timeout: 60 }
    @receiver = Mailman::Receiver::POP3.new(@receiver_options)
  end

  describe 'connection' do
    it 'should connect to a POP3 server' do
      expect(@receiver.connect).to be_truthy
    end

    it 'should disconnect from a POP3 server' do
      @receiver.connect
      expect(@receiver.disconnect).to be_truthy
    end
  end

  describe 'message reception' do
    before do
      @receiver.connect
    end

    it 'should get messages and process them' do
      expect(@processor).to receive(:process).twice.with(/test/)
      @receiver.get_messages
    end

    it 'should delete the messages after processing' do
      @receiver.get_messages
      expect(@receiver.connection.mails).to be_empty
    end
  end

  describe 'started connection' do
    it 'should return the same of connection when started' do
      expect_any_instance_of(MockPOP3).to receive(:started?)
      @receiver.started?
    end
  end
end
