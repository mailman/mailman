require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper'))

describe Mailman::Route::ToCondition do

  it 'should match an address' do
    Mailman::Route::ToCondition.new('test').match(basic_message).should == [{}, []]
  end

  it 'should not match a non-matching address' do
    Mailman::Route::ToCondition.new('foo').match(basic_message).should be_nil
  end

  it 'should not match a nil address' do
    Mailman::Route::ToCondition.new('test').match(Mail.new).should be_nil
  end

  it 'should define a method on Route that is chainable and stores the condition' do
    Mailman::Route.new.to('test').conditions[0].class.should == Mailman::Route::ToCondition
  end

end

describe Mailman::Route::FromCondition do

  it 'should match an address' do
    Mailman::Route::FromCondition.new('chunky').match(basic_message).should == [{}, []]
  end

  it 'should not match a non-matching address' do
    Mailman::Route::FromCondition.new('foo').match(basic_message).should be_nil
  end

  it 'should define a method on Route that is chainable and stores the condition' do
    Mailman::Route.new.from('test').conditions[0].class.should == Mailman::Route::FromCondition
  end

end

describe Mailman::Route::SubjectCondition do

  it 'should match the subject' do
    Mailman::Route::SubjectCondition.new('Hello').match(basic_message).should == [{}, []]
  end

  it 'should not match a non-matching subject' do
    Mailman::Route::SubjectCondition.new('foo').match(basic_message).should be_nil
  end

  it 'should define a method on Route that is chainable and stores the condition' do
    Mailman::Route.new.subject('test').conditions[0].class.should == Mailman::Route::SubjectCondition
  end

end

describe Mailman::Route::BodyCondition do

  it 'should match the body' do
    Mailman::Route::BodyCondition.new('email').match(basic_message).should == [{}, []]
  end

  it 'should not match a non-matching body' do
    Mailman::Route::BodyCondition.new('foo').match(basic_message).should be_nil
  end

  it 'should define a method on Route that is chainable and stores the condition' do
    Mailman::Route.new.body('test').conditions[0].class.should == Mailman::Route::BodyCondition
  end

end

describe Mailman::Route::CcCondition do

  it 'should match an address' do
    Mailman::Route::CcCondition.new('testing').match(basic_message).should == [{}, []]
  end

  it 'should not match a non-matching address' do
    Mailman::Route::CcCondition.new('foo').match(basic_message).should be_nil
  end

  it 'should not match a nil address' do
    Mailman::Route::CcCondition.new('testing').match(Mail.new).should be_nil
  end

  it 'should define a method on Route that is chainable and stores the condition' do
    Mailman::Route.new.cc('testing').conditions[0].class.should == Mailman::Route::CcCondition
  end

end
