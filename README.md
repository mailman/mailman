# Mailman

Mailman is an incoming mail processing microframework (with POP3 and Maildir
support), that works with Rails "out of the box".

    require 'mailman'
    Mailman::Application.run do
      to 'ticket-%id%@example.org' do 
        Ticket.find(params[:id]).add_reply(message)
      end
    end

See the [User Guide](http://rubydoc.info/github/titanous/mailman/master/file/USER_GUIDE.md) for more information.

## Installation

    gem install mailman

## Thanks

This project is sponsored by the [Ruby Summer of Code](http://rubysoc.org),
and my mentor is [Steven Soroka](http://github.com/ssoroka).

### Contributors

    Tim Carey-Smith
    Nicolas Aguttes

## Copyright

Copyright (c) 2010 Jonathan Rudenberg. See LICENSE for details.
