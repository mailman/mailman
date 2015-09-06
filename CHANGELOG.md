## 0.8.0 (April 1, 2015)

Features

  - An HTTP Receiver for creating email-only applications with services like Sendgrid and Cloudmailin
  - Header conditions; route by matching email headers

Bugfixes

  - RBX build issues

Notes

  - Uses the master branch version of `mail` because of a bug when using RBX (see [#116](https://github.com/mailman/mailman/issues/116)). This will be removed when the mail gem is next released.

## 0.7.3 (March 17, 2015)

Features

  - STARTTLS for IMAP
  - Allow passing options to OpenSSL for POP3/IMAP

Security fixes

  - Enable certificate validation for POP3

Bugfixes

  - Added retry logic to handle connection errors gracefully

## 0.7.2 (June 9, 2014)

Bugfixes

  - Allow newer versions of the `listen` gem

## 0.7.1 (June 6, 2014)

Bugfixes

  - Update to listen 2.2.0
  - Handle POP3 receiver crashes better


## 0.7.0 (August 11, 2013)

Features

  - Configurable POP3 open_timeout and read_timeout values
  - Middleware support
  - CLI runner tool
  - Multiple configurations


## 0.6.0 (January 12, 2013)

Features

  - IMAP: Mark messages as seen instead of deleting them (see [5b6aef0](https://github.com/mailman/mailman/commit/5b6aef0163f0f28c790abf3083cbda7cbc9cc13f) for details on how revert to the previous behaviour)

Bugfixes

  - IMAP: Don't only process recent messages


## 0.5.4 (January 3, 2013)

Bufixes

  - Fix multipart message matching
  - Fix Rails environment require
  - Speed up maildir processing


## 0.5.3 (August 30, 2012)

Features

  - Add `watch_maildir` config flag that allows a single run against a maildir
  - Add IMAP SSL and non-inbox folder support


## 0.5.2 (June 13, 2012)

Bugfixes

  - Clear the params hash after each message
  - Allow setting config.rails\_root to false


## 0.5.1 (May 9, 2012)

Bugfixes

  - Check maildir on startup to catch any pre-existing messages
  - Rescue errors while processing messages so that the app doesn't die


## 0.5.0 (April 24, 2012)

Features

  - IMAP support
  - Graceful death

Bugfixes

  - Check all new messages in Maildir when a file changes
  - Don't move message from new to current in Maildir if process failed
  - Avoid require listen if not use
  - Avoid failing if POP3::Connection raises an exception
  - Check multipart bodies properly
  - Use listen gem instead of fssm
  - Don't die if the Rails environment is already loaded


## 0.4.0 (October 3, 2010)

Features

  - The `ignore_stdin` config option has been added

Bugfixes

  - Fix a Mail/ActiveSupport dependency issue with i18n


## 0.3.0 (September 2, 2010)

Features

  - The `CC` condition has been added
  - The router can route to class instance methods as well as blocks
  - SSL is now supported by the POP3 receiver

Bugfixes

  - Fix a bug where messages were not being deleted properly by the POP3
    polling loop
  - Fix empty `To` fields crashing apps


## 0.2.0 (July 28, 2010

Features

 - Add `Application.run` instead of Application.new().run


## 0.1.0 (July 27, 2010)

  Initial release.
