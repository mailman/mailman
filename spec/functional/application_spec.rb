require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe Mailman::Application do

  after do
    Mailman.reset_config!
  end

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
    $stdin.string = nil
  end

  it 'should poll a POP3 server, and process messsages' do
    config.pop3 = { :server => 'example.com',
                    :username => 'chunky',
                    :password => 'bacon' }
    config.poll_interval = 0 # just poll once

    mailman_app {
      from 'chunky@bacon.com' do
        @count ||= 0
        @count += 1
      end
    }

    @app.run
    @app.router.instance_variable_get('@count').should == 2
  end

  it 'should watch a maildir folder for messages' do
    setup_maildir # creates the maildir with a queued message

    config.maildir = File.join(SPEC_ROOT, 'test-maildir')
    test_message_path = File.join(config.maildir, 'new', 'message2')

    mailman_app {
      from 'jdoe@machine.example' do
        @count ||= 0
        @count += 1

        Thread.exit if @count == 2 # exit when we've processed the two messages
      end
    }

    app_thread = Thread.new { @app.run } # run the app in a separate thread so that fssm doesn't block
    FileUtils.cp(File.join(SPEC_ROOT, 'fixtures', 'example01.eml'), test_message_path) # copy a message into place, triggering fssm handler
    app_thread.join # wait for fssm handler
    @app.router.instance_variable_get('@count').should == 2

    FileUtils.rm_r(config.maildir)
  end

end
