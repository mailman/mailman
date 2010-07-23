# Mailman User Guide

## Routes & Conditions

## Receivers

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
is set, Mailman will use Maildir watching as the receiver. The folder should
contain three folders `cur`, `new`, and `tmp`. If the proper folder
structure does not exist, it will be created.

**Example**: `Mailman.config.maildir = '~/Maildir'`


### Rails

`Mailman.config.rails_root` is the location of the root of a Rails app to
load the environment from. If this option is set to `nil`, Rails environment
loading will be disabled.

**Default**: `.`
