require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe 'POP3 receiver' do

  before do
    @receiver_options = { :username => 'user',
                          :password => 'pass',
                          :connection => MockPOP3.new }
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

end

class MockPOP3
  def start(account, password)
    return self if account == 'user' && password == 'pass'
  end

  def finish
    true
  end
end
