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

  it 'should route a message to a class instance method' do
    mailman_app {
      from '%user%@machine.example', FakeMailer
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

  describe "(when config.ignore_stdin)" do
    before do
      Mailman.config.ignore_stdin = true
    end

    it "should not accept a message from STDIN" do
      mailman_app {
        from('jamis@37signals.com') do
          true
        end
      }

      $stdin.string = fixture('example02')
      @app.run.should be_false
      $stdin.string = nil
    end
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

  it 'should handle connection errors and log them to logger.error' do
    config.pop3 = { :server => 'example.com',
                    :username => 'chunky',
                    :password => 'bacon' }
    config.poll_interval = 0 # just poll once

    mock_pop3 = MockPOP3.new
    mock_pop3.should_receive(:start).and_raise(SystemCallError.new("Generic Connection Error"))
    Net::POP3.should_receive(:new).and_return(mock_pop3)
    Mailman.logger.should_receive(:error).with(/unknown error - Generic Connection Error/i)

    mailman_app {
      from 'chunky@bacon.com' do
        @count ||= 0
        @count += 1
      end
    }
    @app.run
    @app.router.instance_variable_get('@count').should == nil
  end

  it 'should poll an IMAP server, and process messsages' do
    config.imap = { :server => 'example.com',
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
    test_message_path_3 = File.join(config.maildir, 'new', 'message3')

    mailman_app {
      from 'jdoe@machine.example' do
        @count ||= 0
        @count += 1
      end
    }

    app_thread = Thread.new { @app.run } # run the app in a separate thread so that fssm doesn't block
    sleep(0.5)
    FileUtils.cp(File.join(SPEC_ROOT, 'fixtures', 'example01.eml'), test_message_path) # copy a message into place, triggering fssm handler
    FileUtils.cp(File.join(SPEC_ROOT, 'fixtures', 'example01.eml'), test_message_path_3) # copy a message into place, triggering fssm handler
    begin
      Timeout::timeout(2) {
        app_thread.join
      }
    rescue Timeout::Error # wait for fssm handler
    end
    @app.router.instance_variable_get('@count').should == 3

    FileUtils.rm_rf(config.maildir)
  end

  it 'should match a multipart endocoded body' do
    mailman_app {
      body /ID (\d+) (OK|NO)/ do
        params[:captures].first.should == '43'
      end
    }

    send_message(fixture('multipart_encoded')).should be_true
  end

end

class FakeMailer

  def receive(message, params)
    message.subject == 'Saying Hello' && params[:user] == 'jdoe'
  end

end
