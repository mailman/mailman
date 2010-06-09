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
      @route = TestRoute.new
      @router.add_route(@route)
    end

    it 'should work without block args' do
      @route.block = lambda { params[:test] == 'test' } 
      @router.route('test').should be_true
    end

    it 'should work with block args' do
      @route.block = lambda { |arg1,arg2| arg1 == 'test' and arg2 == 'testing' and params[:test] == 'test' } 
      @router.route('test').should be_true
    end

  end

end

class TestRoute

  attr_accessor :block

  def match!(message)
    { :block => @block, :params => {:test => 'test'}, :args => ['test', 'testing'] } if message == 'test'
  end
end
