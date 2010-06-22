require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper'))

describe Mailman::Route::Matcher do

  before do
    @matcher = Mailman::Route::Matcher.new('test')
  end

  it 'should have base methods to override' do
    lambda { @matcher.match('test') }.should raise_error(NotImplementedError)
    lambda { Mailman::Route::Matcher.valid_pattern?('test') }.should raise_error(NotImplementedError)
    @matcher.respond_to?(:compile!).should be_true
  end

  it 'should store the pattern' do
    @matcher.pattern.should == 'test'
  end

  it 'should call #compile! when initialized' do
    TestMatcher.new('test').compiled.should be_true
  end

  describe 'singleton' do

    it 'should have an array of registered matchers' do
      Mailman::Route::Matcher.matchers.should include(TestMatcher)
    end

    it 'should be able to find and create a matcher instance' do
      matcher_class = Mailman::Route::Matcher
      original_matchers = matcher_class.instance_variable_get('@matchers')
      matcher_class.instance_variable_set('@matchers', [TestMatcher])
      matcher = matcher_class.create('test')
      matcher.class.should == TestMatcher
      matcher.pattern.should == 'test'
      TestMatcher.validated.should == true
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
