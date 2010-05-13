require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe 'POP3 receiver' do

  before do
    @connection = mock('POP3 Connection')
    @connection.stub!(:start).and_return(true)
    @receiver_options = { :username => 'user',
                          :password => 'pass',
                          :connection => @connection }
    @receiver = Mailman::Receiver::POP3.new(@receiver_options)
  end

  describe 'connecting' do

    it 'should connect to a POP3 server' do
      @receiver.connect.should be_true
    end

  end

end
