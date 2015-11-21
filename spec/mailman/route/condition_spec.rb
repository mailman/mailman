require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper'))

describe Mailman::Route::Condition do
  it 'should have base methods to override' do
    expect { Mailman::Route::Condition.new('test').match('test') }.to raise_error(NotImplementedError)
  end

  it 'should store the matcher' do
    expect(Mailman::Route::Condition.new(/test/).matcher.class).to eq(Mailman::Route::RegexpMatcher)
    expect(Mailman::Route::Condition.new('test').matcher.class).to eq(Mailman::Route::StringMatcher)
  end

  it 'should define condition methods on Route' do
    block = proc { test }
    route = Mailman::Route.new
    expect(route.test('foo')).to eq(route)
    expect(route.test('foo', &block)).to be_truthy
    expect(route.conditions.first.class).to eq(TestCondition)
    expect(route.block).to eq(block)
  end
end

class TestCondition < Mailman::Route::Condition
  def match
    true
  end
end
