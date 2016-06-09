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
      expect(@receiver.connect).to be_truthy
    end

    it 'should disconnect from a IMAP server' do
      @receiver.connect
      expect(@receiver.disconnect).to be_truthy
    end

    it 'should retry on a ByeResponseError from the IMAP server' do
      mock_imap = mock_imap_with_select_error(Net::IMAP::ByeResponseError, 5)
      expect(Net::IMAP).to receive(:new).and_return(mock_imap)
      @receiver.connect
    end

    it 'should retry on a NoResponseError from the IMAP server' do
      mock_imap = mock_imap_with_select_error(Net::IMAP::NoResponseError, 5)
      expect(Net::IMAP).to receive(:new).and_return(mock_imap)
      @receiver.connect
    end

    it 'should raise on other errors from the IMAP server' do
      mock_imap = mock_imap_with_select_error(Net::IMAP::BadResponseError, 1)
      expect(Net::IMAP).to receive(:new).and_return(mock_imap)
      expect{@receiver.connect}.to raise_error(Net::IMAP::BadResponseError)
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

    it 'should delete the messages with delete flag after processing' do
      receiver_options = @receiver_options
      receiver_options[:done_flags] = [Net::IMAP::DELETED]
      receiver = Mailman::Receiver::IMAP.new(receiver_options)
      receiver.connect
      receiver.get_messages
      expect(receiver.connection.search('ALL')).to be_empty
    end

    it 'should mark the messages as seen after processing' do
      @receiver.get_messages
      expect(@receiver.connection.search('UNSEEN')).to be_empty
    end

    it 'should move the message from read folder to seen folder' do
      receiver_options = @receiver_options
      receiver_options[:move_seen] = true
      receiver = Mailman::Receiver::IMAP.new(receiver_options)
      receiver.connect
      receiver.get_messages
      expect(receiver.connection.search('ALL')).to be_empty
    end

  end

  describe 'started connection' do
    it 'should return the same of connection when started' do
      @receiver.connect
      expect_any_instance_of(MockIMAP).to receive(:disconnected?)
      @receiver.started?
    end
  end

  def mock_imap_with_select_error(error_type, attempts)
    mock_imap = MockIMAP.new
    expect(mock_imap).to receive(:select)
      .with(/INBOX/)
      .exactly(attempts).times
      .and_raise(error_type.new(@error_response))
    mock_imap
  end
end
