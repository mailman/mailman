# From https://github.com/mikel/mail/blob/master/spec/spec_helper.rb#L103

class MockPopMail
  def initialize(rfc2822, number)
    @rfc2822 = rfc2822
    @number = number
    @deleted = false
  end

  def pop
    @rfc2822
  end

  def number
    @number
  end

  def to_s
    "#{number}: #{pop}"
  end

  def delete
    @deleted = true
  end

  def deleted?
    @deleted
  end
end

class MockPOP3
  @@start = false

  def initialize
    @@popmails = []
    2.times do |i|
      @@popmails << MockPopMail.new("To: test@example.com\r\nFrom: chunky@bacon.com\r\nSubject: Hello!\r\n\r\nemail message\r\ntest#{i.to_s}", i)
    end
  end

  def self.popmails
    @@popmails.clone
  end

  def each_mail(*args)
    @@popmails.each do |popmail|
      yield popmail
    end
  end

  def mails(*args)
    @@popmails.clone
  end

  def start(*args)
    @@start = true
    block_given? ? yield(self) : self
  end

  def enable_ssl(*args)
    true
  end

  def started?
    @@start == true
  end

  def self.started?
    @@start == true
  end

  def reset
  end

  def finish
    @@start = false
    true
  end

  def delete_all
    if block_given?
      @@popmails.each do |popmail|
        yield popmail
      end
    end
    @@popmails = []
  end
end

require 'net/pop'
class Net::POP3
  def self.new(*args)
    MockPOP3.new
  end
end
