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

        it 'should stop named matching at a space' do
          compiled = @route.compile_condition('Ticket :id')[0]
          compiled.match('Ticket 55 Error')[1].should == '55'
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
          compiled = @route.compile_condition('(:id)+')[0]
          compiled.match('(55)+')[1].should == '55'
        end

      end

    end

  end

end
