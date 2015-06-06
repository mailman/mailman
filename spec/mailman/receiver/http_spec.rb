require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper'))

describe Mailman::Receiver::HTTP do
  class described_class::TestParser
    attr_reader :env
    attr_writer :block
    attr_accessor :parsed_message

    def initialize(opts = {}); end

    def parse(env)
      @env = env
      @block.send unless @block.nil?
      @parsed_message
    end
  end

  before do
    @processor = double('Message Processor', process: true)
    @receiver_options = {
      host: "127.0.0.1",
      port: 80,
      path: "/emails",
      parser: :test,
      processor: @processor
    }

    @basic_env = { 'REQUEST_PATH' => @receiver_options[:path] }

    handler_klass = double('Rack::Handler')
    @handler = instance_double('Rack::Handler::WeBrick')
    allow(@handler).to receive(:run)
    allow(handler_klass).to receive(:pick).and_return(@handler)
    stub_const('Rack::Handler', handler_klass)
  end

  let(:receiver) { described_class.new(@receiver_options) }
  let(:parser)   { receiver.instance_variable_get('@parser') }

  describe '.start_and_block' do
    it 'should start an HTTP server' do
      receiver.start_and_block
      expect(@handler).to have_received(:run).with(
        instance_of(described_class),
        hash_including(
          :Host => @receiver_options[:host],
          :Port => @receiver_options[:port]
        )
      )
    end
  end

  describe 'message reception' do
    it 'should act like a Rack application' do
      expect(receiver).to respond_to(:call).with(1).argument
    end

    context 'successful processing' do
      it 'should deliver the environment to the parser and return 200 OK' do
        response = receiver.send(:call, @basic_env)
        expect(parser.env).to eq(@basic_env)
        expect(response).to eq([200, {}, []])
      end

      it 'should send the parsed Mail::Message to the processor' do
        parser.parsed_message = :fake_msg
        receiver.send(:call, @basic_env)
        expect(@processor).to have_received(:process).with(parser.parsed_message)
      end

      it 'should respond with 404 for other paths' do
        response = receiver.send(:call, { 'REQUEST_PATH' => "/some-other-path" })
        expect(response).to eq([404, {}, []])
      end
    end

    context 'unsuccessful processing' do
      it 'should deliver the environment to the parser and return 200 OK' do
        parser.block = proc { raise }
        response = receiver.send(:call, @basic_env)
        expect(parser.env).to eq(@basic_env)
        expect(response).to eq([500, {}, ["Email processing failed"]])
      end
    end
  end

  describe Mailman::Receiver::HTTP::RawPostParser do

  end

  describe Mailman::Receiver::HTTP::SendgridParser do

  end
end
