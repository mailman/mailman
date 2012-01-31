require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe Mailman::MessageProcessor do

  let(:message) { "To: mikel\r\nFrom: bob\r\nSubject: Hello!\r\n\r\nemail message\r\n" }
  let(:basic_email) { Mail.new message }
  let(:router) { mock('Message Router', :route => false) }
  let(:processor) { Mailman::MessageProcessor.new(:router => router) }
  let(:maildir_message) { m = Maildir::Message.new(@maildir) ; m.write(message) ; m}
  let(:no_from_mail) { Mail.new "To: mikel\r\nSubject: Hello!\r\n\r\nemail message\r\n" }
  
  describe "#process" do
    it 'should process a message and pass it to the router' do
      router.should_receive(:route).with(basic_email).and_return(true)
      processor.process(basic_email).should be_true
    end

    it 'should log in info the new message received' do
      Mailman.logger.should_receive(:info).with("Got new message from '#{basic_email.from.first}' with subject '#{basic_email.subject}'.")
      processor.process(basic_email)
    end
    
    it 'should receive email without from field' do
      Mailman.logger.should_receive(:info).with("Got new message from 'unknown' with subject '#{basic_email.subject}'.")
      processor.process(no_from_mail)
    end
    
  end

  describe "#process_maildir_message" do
    before { setup_maildir }
    it 'should mark message like seen' do
      processor.process_maildir_message(maildir_message)
      maildir_message.should be_seen
    end

    it 'should move to current' do
      processor.process_maildir_message(maildir_message)
      maildir_message.dir.should == :cur
    end

    it 'should not move file in cur if process failed' do
      router.should_receive(:route).with(basic_email).and_raise(Exception)
      begin
        processor.process_maildir_message(maildir_message)
      rescue Exception
      end
      maildir_message.dir.should_not == :cur
    end
  end

end
