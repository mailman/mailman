require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper'))

describe Mailman::Route::StringMatcher do

  it 'should be registered with Matcher' do
    Mailman::Route::Matcher.create('test').class.should == Mailman::Route::StringMatcher
  end

  describe 'compiler' do

    before do
      @matcher = string_matcher('%user%@example.com')
    end

    it 'should compile to a regular expression' do
      @matcher.pattern.should == /(.*)@example\.com/i
    end

    it 'should turn tokens into keys' do
      @matcher.keys.should == [:user]
    end

  end

  describe 'matcher' do

    it 'should return a hash of named params and an array of captures' do
      correct_result = [{ :user_name => 'test', :domain => 'example.com' }, ['test', 'example.com']]
      string_matcher('%user_name%@%domain%').match('test@example.com').should == correct_result
    end

    it 'should return empty results if there are no captures' do
      string_matcher('test@example.com').match('test@example.com').should == [{}, []]
    end

    it 'should match a complex string' do
      matcher = string_matcher('%user%@example.com')
      address = "bob1234!$##%&'*+-/=?^_`{}|.~@example.com"
      matcher.match(address)[1][0].should == "bob1234!$##%&'*+-/=?^_`{}|.~"
    end

    it 'should capture a partial string' do
      matcher = string_matcher('%user%-unsubscribe@example.com')
      matcher.match('test-unsubscribe@example.com')[1][0].should == 'test'
    end

    it 'should not match a non-matching string' do
      string_matcher('foobar').match('fuzz').should be_nil
    end

    it 'should match named params split by a period' do
      matches = string_matcher('test@%domain%.%tld%').match('test@example.com')[1]
      matches[0].should == 'example'
      matches[1].should == 'com'
    end

    it 'should match a pattern with special characters in it' do
      matcher = string_matcher("(%id%)+ ^|$ \n [%foo%]*\?{%bar%}")
      matches = matcher.match("(55)+ ^|$ \n [test]*\?{2}")[1]
      matches[0].should == '55'
      matches[1].should == 'test'
      matches[2].should == '2'
    end

  end

end
