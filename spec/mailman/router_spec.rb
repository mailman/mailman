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

    it 'should work without block args' do
      @route1.block = lambda { params[:test] == 'test' } 
      @router.route('test1').should be_true
    end

    it 'should work with block args' do
      @route1.block = lambda { |arg1,arg2| arg1 == 'test' and arg2 == 'testing' and params[:test] == 'test' } 
      @router.route('test1').should be_true
    end

    describe 'list' do

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

  end

end

class TestRoute

  attr_accessor :block, :correct_message

  def match!(message)
    { :block => @block, :params => {:test => 'test'}, :args => ['test', 'testing'] } if message == @correct_message
  end

end
