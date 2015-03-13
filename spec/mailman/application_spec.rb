require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe Mailman::Application do

  describe 'instance variables' do

    before do
      @app = Mailman::Application.new {}
    end

    it 'should initialize and store the router' do
      expect(@app.router.class).to eq(Mailman::Router)
    end

    it 'should initialize and store the message processor' do
      expect(@app.processor.class).to eq(Mailman::MessageProcessor)
    end

    context "with global config" do
      it 'should use the global config' do
        expect(@app.config.class).to eq(Mailman::Configuration)
        expect(@app.config).to eq(Mailman.config)
      end
    end

    context "passing config on initialization" do
      context "passing a hash" do
        before do
          @app = Mailman::Application.new({poll_interval: 10}) {}
        end

        it "should instanciate the configuration" do
          expect(@app.config).to be_a(Mailman::Configuration)
        end

        it "should instanciate a config instance with params" do
          expect(@app.config.poll_interval).to eq(10)
        end

        it 'should not use the global config' do
          expect(@app.config).to_not eq(Mailman.config)
        end
      end

      context "passing a Configuration instance" do
        before do
          @config = Mailman::Configuration.new
          @config.poll_interval = 10
          @app = Mailman::Application.new(@config) {}
        end

        it "should instanciate the configuration" do
          expect(@app.config).to be_a(Mailman::Configuration)
        end

        it "should instanciate a config instance with params" do
          expect(@app.config.poll_interval).to eq(10)
        end

        it 'should not use the global config' do
          expect(@app.config).to_not eq(Mailman.config)
        end
      end
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
        allow(@mock_receiver).to receive(:connect)
        allow(@mock_receiver).to receive(:get_messages) { Process.kill("INT", $$) }
        expect(@mock_receiver).to receive(:disconnect).at_most(:twice)
        expect(@mock_receiver).to receive(:started?).at_most(:twice)
        allow(Mailman::Receiver::POP3).to receive(:new).and_return(@mock_receiver)

        Mailman.config.pop3 = {}

        Signal.trap("INT") { raise "Application didn't catch SIGINT" }
        @app.run
      end
    end
  end
end
