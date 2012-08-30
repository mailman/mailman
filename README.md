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

There is also a great [Getting Started Guide](http://dansowter.com/mailman-guide/) written by Dan Sowter.


## Installation

    gem install mailman

## Compatibility

Tested on Ruby 1.8.7, 1.9.2, 1.9.3, REE, JRuby 1.7, and Rubinius.

### Dependencies

 * mail >= 2.0.3
 * activesupport >= 2.3.4
 * listen >= 0.4.1
 * maildir >= 0.5.0
 * i18n >= 0.4.1

## Thanks

This project was sponsored by the [Ruby Summer of Code](http://rubysoc.org),
and my mentor was [Steven Soroka](http://github.com/ssoroka).

### Contributors

- [Nicolas Aguttes](http://github.com/tranquiliste)
- [Nathan Broadbent](https://github.com/ndbroadbent)
- [Tim Carey-Smith](http://github.com/halorgium)
- [Dan Cheail](https://github.com/DanCheail)
- [Francis Chong](https://github.com/siuying)
- [Kevin Glowacz](https://github.com/kjg)
- [Cyril Mougel](http://github.com/shingara)
- [Brian Palmer](https://github.com/codekitchen)
- [Phillip Ridlen](https://github.com/philtr)
- [Daniel Schierbeck](http://github.com/dasch)
- [Steven Soroka](http://github.com/ssoroka)
- [Benjamin Waldher](https://github.com/lgbr)
- [Ian White](http://github.com/ianwhite)
- [Andreas Wolff](https://github.com/rubyphunk)


## Copyright

Copyright (c) 2010-2012 Jonathan Rudenberg. See LICENSE for details.
