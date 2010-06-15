require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe Mailman::Application do

  describe 'configuration' do

    it 'should be able to set options' do
      app = mailman_app {
        set :foo, true
        set :bar, 'yes'

        config[:foo].should == true
      }
      app.config['bar'].should == 'yes'
    end

    it 'should enable and disable options' do
      app = mailman_app {
        enable :foo, :bar, :baz
        disable :baz, :biz
      }
      app.config[:foo].should be_true
      app.config[:bar].should be_true
      app.config[:baz].should be_false
      app.config[:biz].should be_false
    end

  end

end
