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

## Continous integration

[![Build Status](https://secure.travis-ci.org/titanous/mailman.png)](https://secure.travis-ci.org/titanous/mailman)

## Thanks

This project was sponsored by the [Ruby Summer of Code](http://rubysoc.org),
and my mentor was [Steven Soroka](http://github.com/ssoroka).

### Contributors

- [Tim Carey-Smith](http://github.com/halorgium)
- [Nicolas Aguttes](http://github.com/tranquiliste)
- [Daniel Schierbeck](http://github.com/dasch)
- [Ian White](http://github.com/ianwhite)
- [Cyril Mougel](http://github.com/shingara)

## Copyright

Copyright (c) 2010 Jonathan Rudenberg. See LICENSE for details.
