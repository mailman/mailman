require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper'))

describe Mailman::Route::StringMatcher do
  it 'should be registered with Matcher' do
    expect(Mailman::Route::Matcher.create('test').class).to eq(Mailman::Route::StringMatcher)
  end

  describe 'compiler' do
    before do
      @matcher = string_matcher('%user%@example.com')
    end

    it 'should compile to a regular expression' do
      expect(@matcher.pattern).to eq(/(.*)@example\.com/i)
    end

    it 'should turn tokens into keys' do
      expect(@matcher.keys).to eq([:user])
    end
  end

  describe 'matcher' do
    it 'should return a hash of named params and an array of captures' do
      correct_result = [{ user_name: 'test', domain: 'example.com' }, ['test', 'example.com']]
      expect(string_matcher('%user_name%@%domain%').match('test@example.com')).to eq(correct_result)
    end

    it 'should return empty results if there are no captures' do
      expect(string_matcher('test@example.com').match('test@example.com')).to eq([{}, []])
    end

    it 'should match a complex string' do
      matcher = string_matcher('%user%@example.com')
      address = "bob1234!$##%&'*+-/=?^_`{}|.~@example.com"
      expect(matcher.match(address)[1][0]).to eq("bob1234!$##%&'*+-/=?^_`{}|.~")
    end

    it 'should capture a partial string' do
      matcher = string_matcher('%user%-unsubscribe@example.com')
      expect(matcher.match('test-unsubscribe@example.com')[1][0]).to eq('test')
    end

    it 'should not match a non-matching string' do
      expect(string_matcher('foobar').match('fuzz')).to be_nil
    end

    it 'should match named params split by a period' do
      matches = string_matcher('test@%domain%.%tld%').match('test@example.com')[1]
      expect(matches[0]).to eq('example')
      expect(matches[1]).to eq('com')
    end

    it 'should match a pattern with special characters in it' do
      matcher = string_matcher("(%id%)+ ^|$ \n [%foo%]*\?{%bar%}")
      matches = matcher.match("(55)+ ^|$ \n [test]*\?{2}")[1]
      expect(matches[0]).to eq('55')
      expect(matches[1]).to eq('test')
      expect(matches[2]).to eq('2')
    end
  end
end
