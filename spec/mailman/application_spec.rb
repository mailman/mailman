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

  describe "#run" do
    describe "when graceful_death flag is set" do
      before do
        Mailman.config.graceful_death = true
        Mailman.config.poll_interval = 0.1
        @app = Mailman::Application.new {}
      end

      it "should catch interrupt signal and let a POP3 receiver finish its poll before exiting" do
        @mock_receiver = double("Receiver::POP3")
        @mock_receiver.stub(:connect)
        @mock_receiver.stub(:get_messages) {Process.kill("INT", $$)}
        @mock_receiver.should_receive(:disconnect).at_most(:twice)
        Mailman::Receiver::POP3.stub(:new) {@mock_receiver}

        Mailman.config.pop3 = {}

        Signal.trap("INT") {raise "Application didn't catch SIGINT"}
        @app.run
      end
    end
  end
end
