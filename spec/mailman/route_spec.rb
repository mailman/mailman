require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe 'Message route' do

  before do
    @route = Mailman::Route.new
    @conditions = [:to, :from, :subject, :body]
  end

  describe 'condition' do

    it 'should be chainable' do
      @conditions.each do |condition|
        @route.send(condition).should == @route
      end
    end

    it 'should set a condition' do
      @conditions.each do |condition|
        @route.send(condition, 'test')
        @route.instance_variable_get("@#{condition}").should == 'test'
      end
    end

    it 'should set a block and return true' do
      @conditions.each do |condition|
        @route.send(condition, 'test') { test }.should === true
        @route.instance_variable_get('@block').class.should == Proc
      end
    end

  end

end
