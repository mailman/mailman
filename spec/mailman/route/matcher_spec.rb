require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper'))

describe Mailman::Route::Matcher do
  before do
    @matcher = Mailman::Route::Matcher.new('test')
  end

  it 'should have base methods to override' do
    expect { @matcher.match('test') }.to raise_error(NotImplementedError)
    expect { Mailman::Route::Matcher.valid_pattern?('test') }.to raise_error(NotImplementedError)
    expect(@matcher.respond_to?(:compile!)).to be_truthy
  end

  it 'should store the pattern' do
    expect(@matcher.pattern).to eq('test')
  end

  it 'should call #compile! when initialized' do
    expect(TestMatcher.new('test').compiled).to be_truthy
  end

  describe 'singleton' do
    it 'should have an array of registered matchers' do
      expect(Mailman::Route::Matcher.matchers).to include(TestMatcher)
    end

    it 'should be able to find and create a matcher instance' do
      matcher_class = Mailman::Route::Matcher
      original_matchers = matcher_class.instance_variable_get('@matchers')
      matcher_class.instance_variable_set('@matchers', [TestMatcher])
      matcher = matcher_class.create('test')
      expect(matcher.class).to eq(TestMatcher)
      expect(matcher.pattern).to eq('test')
      expect(TestMatcher.validated).to eq(true)
      matcher_class.instance_variable_set('@matchers', original_matchers)
    end
  end
end

class TestMatcher < Mailman::Route::Matcher
  attr_reader :compiled

  def compile!
    @compiled = true if @pattern
  end

  class << self
    attr_reader :validated

    def valid_pattern?(pattern)
      @validated = true if pattern
      true
    end
  end
end
