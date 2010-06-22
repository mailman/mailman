require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper'))

describe Mailman::Route::Condition do

  it 'should have base methods to override' do
    lambda { Mailman::Route::Condition.new('test').match('test') }.should raise_error(NotImplementedError)
  end

  it 'should store the matcher' do
    Mailman::Route::Condition.new(/test/).matcher.class.should == Mailman::Route::RegexpMatcher
    Mailman::Route::Condition.new('test').matcher.class.should == Mailman::Route::StringMatcher
  end

  it 'should define condition methods on Route' do
    block = Proc.new { test }
    route = Mailman::Route.new
    route.test('foo').should == route
    route.test('foo', &block).should be_true
    route.conditions.first.class.should == TestCondition
    route.block.should == block
  end

end

class TestCondition < Mailman::Route::Condition
  def match
    true
  end
end
