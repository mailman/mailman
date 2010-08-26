require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe Mailman::Route do

  before do
    @route = Mailman::Route.new
  end

  it 'should match a condition' do
    block = Proc.new { test }
    correct_result = { :block => block, :klass => nil, :params => {:testing => 'test'}, :args => ['testing'] }
    @route.testing('test', &block)
    @route.match!('test').should == correct_result
  end

  it 'should match multiple conditions' do
    block = Proc.new { test }
    correct_result = { :block => block, :klass => nil, :params => {:testing => 'test', :tester => 'test2'}, :args => ['testing', 'test2'] }
    @route.testing('test').tester('test', &block)
    @route.match!('test').should == correct_result
  end

  it 'should not match a non-matching condition' do
    @route.testing('foo').match!('test').should be_nil
  end

  it 'should not match if one condition is non-matching' do
    @route.testing('test').tester('foo').match!('test').should be_nil
  end

end

class TestingCondition < Mailman::Route::Condition
  def match(message)
    [{:testing => 'test'}, ['testing']] if @matcher.match(message)
  end
end

class TesterCondition < Mailman::Route::Condition
  def match(message)
    [{:tester => 'test2'}, ['test2']] if @matcher.match(message)
  end
end
