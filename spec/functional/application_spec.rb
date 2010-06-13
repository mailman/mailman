require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe Mailman::Application do

  it 'should route a message based on the from address' do
    mailman_app {
      from '%user%@machine.example'  do
        params[:user].should == 'jdoe'
        message.subject.should == 'Saying Hello'
      end
    }

    send_message fixture('example01')
  end

end
