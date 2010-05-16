require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe 'Message route' do

  before do
    @route = Mailman::Route.new
    @conditions = [:to, :from, :subject, :body]
  end

  describe 'conditions' do

    it 'should be chainable' do
      @conditions.each do |condition|
        @route.send(condition, 'test').should == @route
      end
    end

    it 'should compile and set the condition' do
      @conditions.each do |condition|
        @route.send(condition, 'test')
        @route.instance_variable_get("@#{condition}")
          .should == @route.compile_condition('test')
      end
    end

    it 'should set a block and return true' do
      @conditions.each do |condition|
        @route.send(condition, 'test') { test }.should === true
        @route.instance_variable_get('@block').class.should == Proc
      end
    end

    it 'should store the order conditions are called' do
      @route.to('test').from('test').conditions.should == [:to, :from]
    end

    describe 'compilation' do

      it 'should compile to a regular expression' do
        @route.compile_condition('test')[0].class.should == Regexp
      end

      it 'should turn tokens into keys' do
        compiled = @route.compile_condition(':user@example.com')
        compiled[0].match('test@example.com')[1].should == 'test'
        compiled[1].should == ['user']
      end

      describe 'regex' do

        it 'should match a complex valid local-part' do
          compiled = @route.compile_condition(':user@example.com')
          address = "bob1234!$##%&'*+-/=?^_`{}|.~@example.com"
          compiled[0].match(address)[1].should == "bob1234!$##%&'*+-/=?^_`{}|.~"
        end

        it 'should match a partial local-part' do
          compiled = @route.compile_condition(':user-unsubscribe@example.com')[0]
          compiled.match('test-unsubscribe@example.com')[1].should == 'test'
        end

        it 'should support multiple named matches' do
          compiled = @route.compile_condition(':user@:host')
          compiled[1].should == ['user', 'host']
          matches = compiled[0].match('test@example.com')
          matches[1].should == 'test'
          matches[2].should == 'example.com'
        end

        it 'should not match a non-matching string' do
          compiled = @route.compile_condition('foobar')[0]
          compiled.match('fuzz').should be_nil
        end

        it 'should match named matches split by a period' do
          compiled = @route.compile_condition('test@:domain.:tld')[0]
          matches = compiled.match('test@example.com')
          matches[1].should == 'example'
          matches[2].should == 'com'
        end

        it 'should match a pattern with special characters in it' do
          compiled = @route.compile_condition("(:id)+ ^|$ \n [:foo]*\?{:bar}")[0]
          match = compiled.match("(55)+ ^|$ \n [test]*\?{2}")
          match[1].should == '55'
          match[2].should == 'test'
          match[3].should == '2'
        end

        it 'should accept a regex' do
          regex = /(.*?)/
          compiled = @route.compile_condition(regex)
          compiled[0].should == regex
        end

      end

    end

  end

  describe 'matching' do

    def basic_message
      Mail.new("To: test@example.com\r\nFrom: chunky@bacon.com\r\nSubject: Hello!\r\n\r\nemail message\r\n")
    end

    it 'should match static to address' do
      block = Proc.new { test }
      @route.to('test@example.com', &block)
      @route.match!(basic_message).should == [block, {}]
    end

    it 'should not match a non-matching to address' do
      @route.to('noone')
      @route.match!(basic_message).should be_nil
    end

    it 'should pass named params' do
      @route.to(':user@:domain.:tld')
      @route.match!(basic_message)[1].should == { 'user'   => 'test',
                                                  'domain' => 'example',
                                                  'tld'    => 'com' }
    end

    it 'should not match with a failed condition' do
      @route.to('test@example.com').from('foobar') { test }
      @route.match!(basic_message).should be_nil
    end

    it 'should match a to and from address' do
      @route.to('test@example.com').from('chunky@bacon.com')
      @route.match!(basic_message).should be_true
    end

  end

end
