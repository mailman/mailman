require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper'))

describe Mailman::Route::HeaderMatcher do
  it 'should be registered with Matcher' do
    expect(Mailman::Route::Matcher.create(to: 'test').class).to eq(described_class)
  end

  describe 'basic' do
    context 'in general' do
      let(:matcher) { header_matcher(:to => 'test', 'from' => /h[i|ello]/) }

      it 'should store a hash' do
        expect(matcher.pattern).to be_a(Hash)
      end

      it 'should store symbol keys' do
        expect(matcher.pattern.keys).to all(be_a(Symbol))
      end

      it 'should store Matcher values' do
        expect(matcher.pattern.values.map(&:class)).to all(be < Mailman::Route::Matcher)
      end
    end

    context 'using strings' do
      let(:matcher) { header_matcher(to: 'test') }

      it 'should match a string' do
        header = Mail::Header.new('To: test@example.com')
        expect(matcher.match(header)).to be_truthy
      end

      it 'should not match a non-matching string' do
        header = Mail::Header.new('To: nope@example.com')
        expect(matcher.match(header)).to be_nil
      end

      it 'should not match a matching string in the wrong field' do
        header = Mail::Header.new('Cc: test@example.com')
        expect(matcher.match(header)).to be_nil
      end
    end

    context 'using regular expressions' do
      let(:matcher) { header_matcher(from: /h[i|ello]/) }

      it 'should match a regular expression' do
        header = Mail::Header.new('From: hi@example.com')
        expect(matcher.match(header)).to be_truthy
      end

      it 'should not match a non-matching regular expression' do
        header = Mail::Header.new('From: nope@example.com')
        expect(matcher.match(header)).to be_nil
      end
    end
  end

  describe 'captures' do
    it 'should return a captures hash and array with matches' do
      correct_captures = ['test', 'example.com']
      header = Mail::Header.new('To: test@example.com')
      expect(header_matcher(to: /(.*)@(.*)/).match(header)).to eq([{
                                                                    captures: {
                                                                      to: [correct_captures]
                                                                    }
                                                                  }, correct_captures])
    end

    it 'should return an array of matches when the same field is sent twice' do
      correct_captures = [['test1'], ['test2']]
      header = Mail::Header.new("X-Custom: test1@example.com\r\nX-Custom: test2@example.com")
      expect(header_matcher(x_custom: /(.*)@example.com/).match(header)).to eq([{
                                                                                 captures: {
                                                                                   x_custom: correct_captures
                                                                                 }
                                                                               }, correct_captures.flatten])
    end

    it 'should return a captures object for each header, even if there were no captures' do
      header = Mail::Header.new("To: test@example.com\r\nFrom: noone@example.com")
      expect(header_matcher(to: /test/, from: 'noone').match(header)).to eq([{ captures: {
                                                                              to: [[]],
                                                                              from: [nil]
                                                                            } }, []])
    end
  end
end
