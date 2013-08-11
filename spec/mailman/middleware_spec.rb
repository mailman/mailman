require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

class ExampleMiddleware
  def call(*args)
    yield
  end
end

class AnotherMiddleware
  def call(*args)
    yield
  end
end

describe Mailman::Middleware do
  let(:middleware) { Mailman::Middleware.new() }

  describe "#add" do
    it "should add middleware to the end of the stack" do
      middleware.add ExampleMiddleware
      middleware.instance_variable_get('@entries').last.should == ExampleMiddleware
    end
  end

  describe "#remove" do
    it "should remove the middleware from the stack" do
      middleware.add AnotherMiddleware
      middleware.remove AnotherMiddleware
      middleware.instance_variable_get('@entries').should be_empty
    end
  end

  describe "#insert_before" do
    it "should add middleware to the correct location in the stack" do
      middleware.add AnotherMiddleware
      middleware.insert_before AnotherMiddleware, ExampleMiddleware
      middleware.instance_variable_get('@entries').first.should == ExampleMiddleware
    end
  end

  describe "#insert_after" do
    it "should add middleware to the correct location in the stack" do
      middleware.add AnotherMiddleware
      middleware.insert_after AnotherMiddleware, ExampleMiddleware
      middleware.instance_variable_get('@entries').last.should == ExampleMiddleware
    end
  end

  describe "#run" do
    it "should run all middleware in the stack" do
      [ExampleMiddleware, AnotherMiddleware].each do |middleware_class|
        middleware.add middleware_class
        middleware_class.any_instance.should_receive(:call).and_call_original
      end

      middleware.run({}) {}
    end
  end
end