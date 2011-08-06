## master

Bugfixes

  - Check all new message in Maildir when only one file change and not
    only file change
  - Don't move message from new to current in Maildir if process failed
  - Avoid require ffsm if not use ( W. Andrew Loe III )
  - Avoid failing if POP3::Connection raise an exception ( Dan Cheail )
  - Check multipart bodies properly. Issue #16


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
