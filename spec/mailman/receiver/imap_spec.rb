require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper'))

describe Mailman::Receiver::IMAP do

  before do
    @processor = double('Message Processor', :process => true)
    @receiver_options = { :username  => 'user',
                          :password  => 'pass',
                          :server    => 'example.com',
                          :folder    => 'INBOX',
                          :processor => @processor }
    @receiver = Mailman::Receiver::IMAP.new(@receiver_options)
    @error_response = double( :data => double( :text => 'Temporary System Error' ) )
  end

  describe 'connection' do

    it 'should connect to a IMAP server' do
      @receiver.connect.should be_true
    end

    it 'should disconnect from a IMAP server' do
      @receiver.connect
      @receiver.disconnect.should be_true
    end

    it 'should retry on a ByeResponseError from the IMAP server' do
      mock_imap = mock_imap_with_select_error(Net::IMAP::ByeResponseError, 5)
      Net::IMAP.should_receive(:new).and_return(mock_imap)
      @receiver.connect
    end

    it 'should retry on a NoResponseError from the IMAP server' do
      mock_imap = mock_imap_with_select_error(Net::IMAP::NoResponseError, 5)
      Net::IMAP.should_receive(:new).and_return(mock_imap)
      @receiver.connect
    end

    it 'should raise on other errors from the IMAP server' do
      mock_imap = mock_imap_with_select_error(Net::IMAP::BadResponseError, 1)
      Net::IMAP.should_receive(:new).and_return(mock_imap)
      expect{@receiver.connect}.to raise_error(Net::IMAP::BadResponseError)
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

  def mock_imap_with_select_error(error_type, attempts)
    mock_imap = MockIMAP.new
    mock_imap
      .should_receive(:select)
      .with(/INBOX/)
      .exactly(attempts).times
      .and_raise(error_type.new(@error_response))
    mock_imap
  end

end
