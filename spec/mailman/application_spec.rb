require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe Mailman::Application do

  it "should be able to configure options" do
    app = mailman_app {
      set :foo, true
      set :bar, 'yes'

      config[:foo].should == true
    }
    app.config['bar'].should == 'yes'
  end

end
