require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe Mailman::Router do

  before do
    @router = Mailman::Router.new
  end

  it 'should add a route' do
    expect(@router.add_route('test')).to eq('test')
    expect(@router.routes).to eq(['test'])
  end

  describe 'routing' do

    before do
      @route1 = TestRoute.new
      @route1.correct_message = 'test1'
      @router.add_route(@route1)
    end

    describe 'blocks' do

      it 'should work without args' do
        @route1.block = lambda {
          raise "Params unavailable" unless params[:test] == 'test'
          raise "Message unavailable" unless message == 'test1'
        }
        @router.route('test1')
      end

      it 'should work with args' do
        @route1.block = lambda { |arg1, arg2|
          raise "Argument 1 unavailable" unless arg1 == 'test'
          raise "Argument 2 unavailable" unless arg2 == 'testing'
          raise "Params unavailable" unless params[:test] == 'test'
          raise "Message unavailable" unless message == 'test1'
        }
        @router.route('test1')
      end

    end

    describe 'class instance methods' do

      it 'should route to the default method' do
        @route1.klass = TestMailer
        expect(@router.route('test1')).to be_truthy
      end

      it 'should route to the specified method' do
        @route1.klass = 'testMailer#get'
        expect(@router.route('test1')).to be_truthy
      end

    end

    it 'should set the params helper to a indifferent hash' do
      @route1.block = proc {
        raise "Symbol access unavailable" unless params[:test] == 'test'
        raise "String access unavailable" unless params['test'] == 'test'
      }
      @router.route('test1')
    end

    describe 'array' do

      before do
        @route2 = TestRoute.new
        @router.add_route(@route2)
      end

      it 'should loop through routes and find the first route that matches' do
        @route2.block = lambda { 2 }
        @route2.correct_message = 'test2'
        expect(@router.route('test2')).to eq(2)
      end

      it 'should run the first route that matches with two matching routes' do
        @route2.correct_message = 'test1'
        @route1.block = lambda { 1 }
        @route2.block = lambda { 2 }
        expect(@router.route('test1')).to eq(1)
      end

    end

    describe 'bounces' do

      before do
        @router.bounce_block = lambda { 'bounce' }
      end

      it 'should run the bounce block if it exists' do
        message = double('bounced message', :bounced? => true)
        @route1.correct_message = message
        expect(@router.route(message)).to eq('bounce')
      end

      it 'should not run the bounce block if the message did not bounce' do
        message = double('bounced message', :bounced? => false)
        @route1.correct_message = message
        @route1.block = lambda { 'nobounce' }
        expect(@router.route(message)).to eq('nobounce')
      end

    end

    describe 'default' do

      before do
        @router.default_block = lambda { 'default' }
      end

      it 'should run the default block if it exists and no routes match' do
        @route1.correct_message = 'foobar'
        expect(@router.route('blah')).to eq('default')
      end

      it 'should not run the default block if a route matched' do
        @route1.correct_message = 'test'
        @route1.block = lambda { 'nodefault' }
        expect(@router.route('test')).to eq('nodefault')
      end

    end

  end

end

class TestRoute

  attr_accessor :block, :correct_message, :klass

  def match!(message)
    { :block => @block, :klass => @klass, :params => {:test => 'test'}, :args => ['test', 'testing'] } if message == @correct_message
  end

end

class TestMailer

  def receive(message, params)
    message == 'test1' && params[:test] == 'test'
  end

  alias_method :get, :receive

end
