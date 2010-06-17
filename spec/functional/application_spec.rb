require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe Mailman::Application do

  def send_example
    send_message(fixture('example01')).should be_true
  end

  it 'should route a message based on the from address' do
    mailman_app {
      from '%user%@machine.example'  do
        params[:user].should == 'jdoe'
        message.subject.should == 'Saying Hello'
      end
    }

    send_example
  end

  it 'should route a message based on the from and to addresses' do
    mailman_app {
      from('jdoe@machine.example').to(/(.+)@(.+)/) do |to_user, to_domain|
        params[:captures].first.should == 'mary'
        to_domain.should == 'example.net'
      end
    }

    send_example
  end

  it "should route a message that doesn't match to the default block" do
    mailman_app {
      from('foobar@example.net') do
        false.should be_true # we're not supposed to be here
      end

      default do
        message.subject.should == 'Saying Hello'
      end
    }

    send_example
  end

  it "should accept a message from STDIN" do
    mailman_app {
      from('jamis@37signals.com') do
        true
      end
    }

    $stdin.string = fixture('example02')
    @app.run.should be_true
  end

end
