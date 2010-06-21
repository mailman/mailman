require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe Mailman::Application do

  describe 'instance variables' do

    before do
      @app = Mailman::Application.new {}
    end

    it 'should initialize and store the router' do
      @app.router.class.should == Mailman::Router
    end

    it 'should initialize and store the message processor' do
      @app.processor.class.should == Mailman::MessageProcessor
    end

  end

end
