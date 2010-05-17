require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper'))

describe Mailman::Route::RegexpMatcher do


  describe 'basic' do

    before do 
      @matcher = Mailman::Route::RegexpMatcher.new(/test/)
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
      matcher = Mailman::Route::RegexpMatcher.new(/(.*)@(.*)/)
      correct_captures = ['test', 'example.com']
      matcher.match('test@example.com').should == [{:captures => correct_captures}, correct_captures]
    end

    it 'should return empty capture arrays if there were no captures' do
      matcher = Mailman::Route::RegexpMatcher.new(/test/)
      matcher.match('test').should == [{:captures => []}, []]
    end

  end

end
