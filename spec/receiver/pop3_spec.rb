require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe 'POP3 receiver' do

  before do
    @processor = mock('Message Processor', :process => true)
    @receiver_options = { :username => 'user',
                          :password => 'pass',
                          :connection => MockPOP3.new,
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

  end

end

class MockPOP3
  def start(account, password)
    return self if account == 'user' && password == 'pass'
  end

  def finish
    true
  end

  def each_mail(&block)
    2.times do
      yield Spec::Mocks::Mock.new('Message', :pop => 'Email Message')
    end
  end
end
