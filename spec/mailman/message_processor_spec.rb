require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe Mailman::MessageProcessor do

  let(:message) { "To: mikel\r\nFrom: bob\r\nSubject: Hello!\r\n\r\nemail message\r\n" }
  let(:basic_email) { Mail.new message }
  let(:router) { double('Message Router', :route => false) }
  let(:processor) { Mailman::MessageProcessor.new(:router => router, :config => Mailman.config) }
  let(:maildir_message) { m = Maildir::Message.new(@maildir) ; m.write(message) ; m}
  let(:no_from_mail) { Mail.new "To: mikel\r\nSubject: Hello!\r\n\r\nemail message\r\n" }

  describe "#process" do
    it 'should process a message and pass it to the router' do
      expect(router).to receive(:route).with(basic_email).and_return(true)
      expect(processor.process(basic_email)).to be_truthy
    end

    it 'should log in info the new message received' do
      expect(Mailman.logger).to receive(:info).with("Got new message from '#{basic_email.from.first}' with subject '#{basic_email.subject}'.")
      processor.process(basic_email)
    end

    it 'should receive email without from field' do
      expect(Mailman.logger).to receive(:info).with("Got new message from 'unknown' with subject '#{basic_email.subject}'.")
      processor.process(no_from_mail)
    end

  end

  describe "#process_maildir_message" do
    before { setup_maildir }
    it 'should mark message like seen' do
      processor.process_maildir_message(maildir_message)
      expect(maildir_message).to be_seen
    end

    it 'should move to current' do
      processor.process_maildir_message(maildir_message)
      expect(maildir_message.dir).to eq(:cur)
    end

    it 'should not move file in cur if process failed' do
      expect(router).to receive(:route).with(basic_email).and_raise(Exception)
      begin
        processor.process_maildir_message(maildir_message)
      rescue Exception
      end
      expect(maildir_message.dir).to_not eq(:cur)
    end

    it 'should log errors caused by processing the message, but not raise them so futher messages can be processed' do
      error = StandardError.new('testing')
      expect(router).to receive(:route).with(basic_email).and_raise(error)
      expect(Mailman.logger).to receive(:error)
      expect(lambda{ processor.process_maildir_message(maildir_message) }).to_not raise_error
    end
  end

end
