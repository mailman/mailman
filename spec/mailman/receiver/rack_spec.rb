require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper'))

require 'rack/mock'

describe Mailman::Receiver::Rack do

  before do
    @processor = mock('Message Processor', :process => true)
    @receiver  = Mailman::Receiver::Rack.new(:processor => @processor)
  end

  describe 'message reception' do
    
    it 'should process a message delivered over POST' do
      request = Rack::MockRequest.new(@receiver)
      @processor.should_receive(:process).with("foo")

      request.post("/", :params => {:message => "foo"})
    end

  end

end
