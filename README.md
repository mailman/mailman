# Mailman [![Build Status](https://secure.travis-ci.org/mailman/mailman.png)](https://secure.travis-ci.org/mailman/mailman)

Mailman is an incoming mail processing microframework (with POP3 and Maildir
support), that works with Rails "out of the box".

```ruby
require 'mailman'
Mailman::Application.run do
  to 'ticket-%id%@example.org' do 
    Ticket.find(params[:id]).add_reply(message)
  end
end
```

See the [User Guide](https://github.com/mailman/mailman/blob/master/USER_GUIDE.md) for more information.

**If you'd like to maintain this gem, email jonathan@titanous.com.**

## Installation

    gem install mailman

## Compatibility

Tested on Ruby 2.1, 2.0, 1.9.3, JRuby, and Rubinius.

### Ruby < 2.0.0

In order to use this gem with ruby versions older then 2.0.0, you have to
restrict the maildir gem to the latest supported version in your `Gemfile`:

    gem 'maildir', '< 2.1.0'

## Thanks

This project was originally sponsored by Ruby Summer of Code (2010), and
mentored by [Steven Soroka](http://github.com/ssoroka).

## Copyright

Copyright (c) 2010-2013 Jonathan Rudenberg. See LICENSE for details.
