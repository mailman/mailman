require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

class ExampleMiddleware
  def call(*_args)
    yield
  end
end

class AnotherMiddleware
  def call(*_args)
    yield
  end
end

describe Mailman::Middleware do
  let(:middleware) { Mailman::Middleware.new }

  describe '#add' do
    it 'should add middleware to the end of the stack' do
      middleware.add ExampleMiddleware
      expect(middleware.instance_variable_get('@entries').last).to eq(ExampleMiddleware)
    end
  end

  describe '#remove' do
    it 'should remove the middleware from the stack' do
      middleware.add AnotherMiddleware
      middleware.remove AnotherMiddleware
      expect(middleware.instance_variable_get('@entries')).to be_empty
    end
  end

  describe '#insert_before' do
    it 'should add middleware to the correct location in the stack' do
      middleware.add AnotherMiddleware
      middleware.insert_before AnotherMiddleware, ExampleMiddleware
      expect(middleware.instance_variable_get('@entries').first).to eq(ExampleMiddleware)
    end
  end

  describe '#insert_after' do
    it 'should add middleware to the correct location in the stack' do
      middleware.add AnotherMiddleware
      middleware.insert_after AnotherMiddleware, ExampleMiddleware
      expect(middleware.instance_variable_get('@entries').last).to eq(ExampleMiddleware)
    end
  end

  describe '#run' do
    it 'should run all middleware in the stack' do
      [ExampleMiddleware, AnotherMiddleware].each do |middleware_class|
        middleware.add middleware_class
        allow_any_instance_of(middleware_class).to receive(:call).and_call_original
      end

      middleware.run({}) {}
    end
  end
end
