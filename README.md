# Mailman [![Build Status](https://secure.travis-ci.org/titanous/mailman.png)](https://secure.travis-ci.org/titanous/mailman)

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

See the [User Guide](https://github.com/titanous/mailman/blob/master/USER_GUIDE.md) for more information.


## Installation

    gem install mailman

## Compatibility

Tested on Ruby 2.0, 1.9.3, JRuby, and Rubinius.

## Thanks

This project was originally sponsored by Ruby Summer of Code (2010), and
mentored by [Steven Soroka](http://github.com/ssoroka).

## Copyright

Copyright (c) 2010-2013 Jonathan Rudenberg. See LICENSE for details.
