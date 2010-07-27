# Mailman User Guide

## Routes & Conditions

## Receivers

There are currently three types of receivers in Mailman: Standard Input,
Maildir, and POP3. If IMAP or any complex setups are required, use a mail
retriever like [getmail](http://pyropus.ca/software/getmail/) with the
Maildir receiver.


### Standard Input

If a message is piped to a Mailman app, this reciever will override any
configured receivers. The app will process the message, and then quit. This
receiver is useful for testing and debugging.

**Example**: `cat plain_message.eml | ruby mailman_app.rb`


### POP3

The POP3 receiver is enabled when the `Mailman.config.pop3` hash is set. It
will poll every minute by default (this can be changed with
`Mailman.config.poll_interval`). After new messages are processed, they will
be deleted from the server. *No copy of messages will be saved anywhere
after processing*. If you want to keep a copy of messages, it is recommended
that you use a mail retriever with the Maildir receiver.


### Maildir

The Maildir receiver is enabled when `Mailman.config.maildir` is set to a
directory. If the `cur`, `new`, and `tmp` folders do not already exist in
the folder, they will be created. All messages in `new` folder will be
processed when the application launches, then moved to the `cur` folder, and
marked as seen. After processing these messages, Mailman will use the
[fssm](http://github.com/ttilley/fssm) gem to monitor the `new` folder, and
process messages as they are created.

## Configuration

Configuration is stored in the `Mailman.config` object. All paths are
relative to the process's working directory or absolute if starting with a
`/`.


### Logging

`Mailman.config.logger` can be set to a `Logger` instance. You should
change this if you want to log to a file in production.

**Example**: `Mailman.config.logger = Logger.new('logs/mailman.log')`

**Default**: `Logger.new(STDOUT)`


### POP3 Receiver

`Mailman.config.pop3` stores an optional POP3 configuration hash. If it is
set, Mailman will use POP3 polling as the receiver.

**Example**:

    Mailman.config.pop3 = {
      :username => chunky,
      :password => bacon,
      :server   => example.org,
      :port     => 110 # defaults to 110
    }


### Polling

`Mailman.config.poll_interval` is the duration in seconds to wait between
checking for new messages on the server. It is currently only used by the
POP3 reciever. If it is set to `0`, Mailman will do a one-time retrieval and
then exit.

**Default**: `60`


### Maildir

`Mailman.config.maildir` is the location of a Maildir folder to watch. If it
is set, Mailman will use Maildir watching as the receiver.

**Example**: `Mailman.config.maildir = '~/Maildir'`


### Rails

`Mailman.config.rails_root` is the location of the root of a Rails app to
load the environment from. If this option is set to `nil`, Rails environment
loading will be disabled.

**Default**: `.`
