require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe Mailman::MessageProcessor do

  def basic_email
    "To: mikel\r\nFrom: bob\r\nSubject: Hello!\r\n\r\nemail message\r\n"
  end

  before do
    @router = mock('Message Router')
    @processor = Mailman::MessageProcessor.new(:router => @router)
  end

  it 'should process an message and pass it to the router' do
    @router.should_receive(:route).with(Mail.new(basic_email)).and_return(true)
    @processor.process(basic_email).should be_true
  end

end
