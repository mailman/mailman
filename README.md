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

There is also a great [Getting Started Guide](http://dansowter.com/mailman-guide/) written by Dan Sowter.


## Installation

    gem install mailman

## Requirement

Works fine with Ruby >= 1.8.7, rubinius and jRuby. Does not work with Ruby
1.8.6.

### Gems dependencies

 * mail >= 2.0.3
 * activesupport >= 2.3.4
 * fssm >= 0.1.4
 * maildir >= 0.5.0
 * i18n >= 0.4.1

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
