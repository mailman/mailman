require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper'))

describe Mailman::Route::ToCondition do
  it 'should match an address' do
    expect(Mailman::Route::ToCondition.new('test').match(basic_message)).to eq([{}, []])
  end

  it 'should not match a non-matching address' do
    expect(Mailman::Route::ToCondition.new('foo').match(basic_message)).to be_nil
  end

  it 'should not match a nil address' do
    expect(Mailman::Route::ToCondition.new('test').match(Mail.new)).to be_nil
  end

  it 'should define a method on Route that is chainable and stores the condition' do
    expect(Mailman::Route.new.to('test').conditions[0].class).to eq(Mailman::Route::ToCondition)
  end
end

describe Mailman::Route::FromCondition do
  it 'should match an address' do
    expect(Mailman::Route::FromCondition.new('chunky').match(basic_message)).to eq([{}, []])
  end

  it 'should not match a non-matching address' do
    expect(Mailman::Route::FromCondition.new('foo').match(basic_message)).to be_nil
  end

  it 'should define a method on Route that is chainable and stores the condition' do
    expect(Mailman::Route.new.from('test').conditions[0].class).to eq(Mailman::Route::FromCondition)
  end
end

describe Mailman::Route::SubjectCondition do
  it 'should match the subject' do
    expect(Mailman::Route::SubjectCondition.new('Hello').match(basic_message)).to eq([{}, []])
  end

  it 'should not match a non-matching subject' do
    expect(Mailman::Route::SubjectCondition.new('foo').match(basic_message)).to be_nil
  end

  it 'should define a method on Route that is chainable and stores the condition' do
    expect(Mailman::Route.new.subject('test').conditions[0].class).to eq(Mailman::Route::SubjectCondition)
  end
end

describe Mailman::Route::BodyCondition do
  it 'should match the body' do
    expect(Mailman::Route::BodyCondition.new('email').match(basic_message)).to eq([{}, []])
  end

  it 'should not match a non-matching body' do
    expect(Mailman::Route::BodyCondition.new('foo').match(basic_message)).to be_nil
  end

  it 'should define a method on Route that is chainable and stores the condition' do
    expect(Mailman::Route.new.body('test').conditions[0].class).to eq(Mailman::Route::BodyCondition)
  end

  it 'returns nil for a non-matching body of a multipart message' do
    expect(Mailman::Route::BodyCondition.new('foo').match(multipart_message)).to be_nil
  end

  it 'matches on the body of a multipart message' do
    expect(Mailman::Route::BodyCondition.new('plain').match(multipart_message)).to eq([{}, []])
  end
end

describe Mailman::Route::CcCondition do
  it 'should match an address' do
    expect(Mailman::Route::CcCondition.new('testing').match(basic_message)).to eq([{}, []])
  end

  it 'should not match a non-matching address' do
    expect(Mailman::Route::CcCondition.new('foo').match(basic_message)).to be_nil
  end

  it 'should not match a nil address' do
    expect(Mailman::Route::CcCondition.new('testing').match(Mail.new)).to be_nil
  end

  it 'should define a method on Route that is chainable and stores the condition' do
    expect(Mailman::Route.new.cc('testing').conditions[0].class).to eq(Mailman::Route::CcCondition)
  end
end

describe Mailman::Route::HeaderCondition do
  it 'should match a header' do
    expect(Mailman::Route::HeaderCondition.new(to: 'test').match(basic_message)).to be_truthy
  end

  it 'should not match a non-matching header value' do
    expect(Mailman::Route::HeaderCondition.new(to: 'nope').match(basic_message)).to be_nil
  end

  it 'should not match message with no defined header' do
    expect(Mailman::Route::HeaderCondition.new(foo: 'Bar').match(basic_message)).to be_nil
  end

  it 'should define a method on Route that is chainable and stores the condition' do
    expect(Mailman::Route.new.header(foo: 'bar').conditions[0].class).to eq(Mailman::Route::HeaderCondition)
  end

  it 'should not pass when some headers do not match' do
    expect(Mailman::Route::HeaderCondition.new(to: 'test', from: 'streaky').match(basic_message)).to be_nil
  end
end
