require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper'))

describe Mailman::Route::RegexpMatcher do
  it 'should be registered with Matcher' do
    expect(Mailman::Route::Matcher.create(/test/).class).to eq(Mailman::Route::RegexpMatcher)
  end

  describe 'basic' do
    before do
      @matcher = regexp_matcher(/test/)
    end

    it 'should store a pattern' do
      expect(@matcher.pattern).to eq(/test/)
    end

    it 'should match a string' do
      expect(@matcher.match('test')).to be_truthy
    end

    it 'should not match a non-matching string' do
      expect(@matcher.match('foo')).to be_nil
    end
  end

  describe 'captures' do
    it 'should return a captures hash and array with matches' do
      correct_captures = ['test', 'example.com']
      expect(regexp_matcher(/(.*)@(.*)/).match('test@example.com')).to eq([{ captures: correct_captures }, correct_captures])
    end

    it 'should return empty capture arrays if there were no captures' do
      expect(regexp_matcher(/test/).match('test')).to eq([{ captures: [] }, []])
    end
  end
end
