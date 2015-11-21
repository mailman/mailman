#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.join(__dir__, '../lib'))
require 'mailman'

# This example will process emails sent via Sendgrid and create
# a text file for every email sent to 'message-<number>@yourdomain.com' containing
# the email address that last sent a message to that number.
#
# 1. Set up a Sendgrid account
# 2. Point your domain's MX record at `mx.sendgrid.net`
# 3. Configure Sendgrid to point to wherever you're running this example (port 6245)
# 4. Profit!

Mailman.config.http = {
  host: '0.0.0.0',
  port: 6245,
  parser: :sendgrid
}

Mailman::Application.run do
  to /^message-(\d+)@/ do
    open("#{params['captures'].first}.txt", 'w') do |f|
      f.write message.from.join(', ')
    end
  end
end
