require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))
require 'timeout'

describe Mailman::Application do

  before do
    config.watch_maildir = false
  end

  after do
    Mailman.reset_config!
    listener = @app.instance_variable_get('@listener')
    begin
      listener.stop unless listener.nil?
    rescue SystemExit # eat listen exit
    end
  end

  def send_example
    send_message(fixture('example01'))
  end

  it 'should route a message based on the from address' do
    mailman_app {
      from '%user%@machine.example'  do
        raise "Params Unavailable" unless params[:user] == 'jdoe'
        raise "Subject Unavailable" unless message.subject == 'Saying Hello'
      end
    }

    send_example
  end

  it 'should route a message based on the from and to addresses' do
    mailman_app {
      from('jdoe@machine.example').to(/(.+)@(.+)/) do |to_user, to_domain|
        raise "Captures Unavailable" unless params[:captures].first == 'mary'
        raise "To Domain Unavailable" unless to_domain == 'example.net'
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
        raise "We're not supposed to be here"
      end

      default do
        raise "Subject Unavailable" unless message.subject == 'Saying Hello'
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
    expect(@app.run).to be_truthy
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
      expect(@app.run).to be_falsey
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
    expect(@app.router.instance_variable_get('@count')).to eq(2)
  end

  it 'should handle connection errors and log them to logger.error' do
    config.pop3 = { :server => 'example.com',
                    :username => 'chunky',
                    :password => 'bacon' }
    config.poll_interval = 0 # just poll once

    mock_pop3 = MockPOP3.new
    expect(mock_pop3).to receive(:start).exactly(5).times.and_raise(SystemCallError.new("Generic Connection Error"))
    expect(Net::POP3).to receive(:new).and_return(mock_pop3)
    expect(Mailman.logger).to receive(:error).with(/Retrying.../i).exactly(4).times
    expect(Mailman.logger).to receive(:error).with(/unknown error - Generic Connection Error/i).exactly(5).times

    mailman_app {
      from 'chunky@bacon.com' do
        @count ||= 0
        @count += 1
      end
    }
    @app.run
    expect(@app.router.instance_variable_get('@count')).to be_nil
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
    expect(@app.router.instance_variable_get('@count')).to eq(2)
  end

  it 'should process new messages in the maildir folder on launch' do
    setup_maildir # creates the maildir with a queued message

    config.maildir = File.join(SPEC_ROOT, 'test-maildir')

    mailman_app {
      from 'jdoe@machine.example' do
        @count ||= 0
        @count += 1
      end
    }

    @app.run
    expect(@app.router.instance_variable_get('@count')).to eq(1)

    FileUtils.rm_rf(config.maildir)
  end

  it 'should be ready to process a maildir folder before #run is called' do
    setup_maildir # creates the maildir with a queued message

    config.maildir = File.join(SPEC_ROOT, 'test-maildir')
    mailman_app {
      from 'jdoe@machine.example' do
        @count ||= 0
        @count += 1
      end
    }

    @app.run
    expect(@app.router.instance_variable_get('@count')).to eq(1)

    FileUtils.rm_rf(config.maildir)
  end

  it 'should watch a maildir folder for messages' do
    setup_maildir # creates the maildir with a queued message

    config.watch_maildir = true
    config.maildir = File.join(SPEC_ROOT, 'test-maildir')
    test_message_path = File.join(config.maildir, 'new', 'message2')
    test_message_path_3 = File.join(config.maildir, 'new', 'message3')

    mailman_app {
      from 'jdoe@machine.example' do
        @count ||= 0
        @count += 1
      end
    }

    if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx'
      pending "RBX threads != MRI threads; tests stall here."
      raise "Killing test before it stalls"
    end

    Timeout::timeout(10) do
      app_thread = Thread.new { @app.run } # run the app in a separate thread so that listen doesn't block
      sleep(THREAD_TIMING)
      FileUtils.cp(File.join(SPEC_ROOT, 'fixtures', 'example01.eml'), test_message_path) # copy a message into place, triggering listen handler
      FileUtils.cp(File.join(SPEC_ROOT, 'fixtures', 'example01.eml'), test_message_path_3) # copy a message into place, triggering listen handler
      sleep(0.5)
      app_thread.kill
      count = @app.router.instance_variable_get('@count')
      # FIXME: Interacting with the count variable at this point causes the stall
      expect(count).to eq(3)
      FileUtils.rm_rf(config.maildir)
    end
  end

  it 'should match a multipart endocoded body' do
    mailman_app {
      body /ID (\d+) (OK|NO)/ do
        raise "Captures Unavailable" unless params[:captures].first == '43'
      end
    }

    send_message(fixture('multipart_encoded'))
  end

end

class FakeMailer

  def receive(message, params)
    message.subject == 'Saying Hello' && params[:user] == 'jdoe'
  end

end
