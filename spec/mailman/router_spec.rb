require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe Mailman::Router do

  before do
    @router = Mailman::Router.new
  end

  it 'should add a route' do
    @router.add_route('test').should == 'test'
    @router.routes.should == ['test']
  end

  describe 'routing' do

    before do 
      @route1 = TestRoute.new
      @route1.correct_message = 'test1'
      @router.add_route(@route1)
    end

    describe 'blocks' do

      it 'should work without args' do
        @route1.block = lambda { params[:test].should == 'test'
                                 message.should == 'test1' } 
        @router.route('test1')
      end

      it 'should work with args' do
        @route1.block = lambda { |arg1,arg2| arg1.should == 'test'
                                             arg2.should == 'testing'
                                             params[:test].should == 'test'
                                             message.should == 'test1' } 
        @router.route('test1')
      end

    end

    describe 'class instance methods' do

      it 'should route to the default method' do
        @route1.klass = TestMailer
        @router.route('test1').should be_true
      end

      it 'should route to the specified method' do
        @route1.klass = 'testMailer#get'
        @router.route('test1').should be_true
      end

    end

    it 'should set the params helper to a indifferent hash' do
      @route1.block = lambda { params[:test].should == 'test'
                               params['test'].should == 'test' } 
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
        @router.route('test2').should == 2
      end

      it 'should run the first route that matches with two matching routes' do
        @route2.correct_message = 'test1'
        @route1.block = lambda { 1 }
        @route2.block = lambda { 2 }
        @router.route('test1').should == 1
      end

    end

    describe 'bounces' do

      before do
        @router.bounce_block = lambda { 'bounce' }
      end

      it 'should run the bounce block if it exists' do
        message = mock('bounced message', :bounced? => true)
        @route1.correct_message = message
        @router.route(message).should == 'bounce'
      end

      it 'should not run the bounce block if the message did not bounce' do
        message = mock('bounced message', :bounced? => false)
        @route1.correct_message = message
        @route1.block = lambda { 'nobounce' }
        @router.route(message).should == 'nobounce'
      end

    end

    describe 'default' do

      before do
        @router.default_block = lambda { 'default' }
      end

      it 'should run the default block if it exists and no routes match' do
        @route1.correct_message = 'foobar'
        @router.route('blah').should == 'default'
      end

      it 'should not run the default block if a route matched' do
        @route1.correct_message = 'test'
        @route1.block = lambda { 'nodefault' }
        @router.route('test').should == 'nodefault'
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
