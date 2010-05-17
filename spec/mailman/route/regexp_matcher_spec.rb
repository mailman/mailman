require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper'))

describe Mailman::Route::RegexpMatcher do

  it 'should be registered with Matcher' do
    Mailman::Route::Matcher.create(/test/).class.should == Mailman::Route::RegexpMatcher
  end

  describe 'basic' do

    before do 
      @matcher = regexp_matcher(/test/)
    end

    it 'should store a pattern' do
      @matcher.pattern.should == /test/
    end

    it 'should match a string' do
      @matcher.match('test').should be_true
    end

    it 'should not match a non-matching string' do
      @matcher.match('foo').should be_nil
    end

  end

  describe 'captures' do

    it 'should return a captures hash and array with matches' do
      correct_captures = ['test', 'example.com']
      regexp_matcher(/(.*)@(.*)/).match('test@example.com').should == [{:captures => correct_captures}, correct_captures]
    end

    it 'should return empty capture arrays if there were no captures' do
      regexp_matcher(/test/).match('test').should == [{:captures => []}, []]
    end

  end

end
