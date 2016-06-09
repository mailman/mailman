# Mailman User Guide

Mailman is a microframework for processing incoming email.

Here is an example Mailman app that takes incoming messages to a support
email account, and adds them to a database.

```ruby
# mailman_app.rb
require 'mailman'

Mailman.config.maildir = '~/Maildir'

Mailman::Application.run do
  to 'support@example.org' do
    Ticket.new_from_message(message)
  end
end
```

The Mailman app could then be started by running `ruby mailman_app.rb`.

## Installation

Installation is as simple as `gem install mailman`.


## Routes & Conditions

A **Condition** specifies the part of the message to match against. `to`,
`from`, and `subject` are some valid conditions. A **Matcher** is used by a
condition to determine whether it matches the message. Matchers can be
strings or regular expressions. One or more Condition/Matcher pairs are
combined with a block of code to form a **Route**.

### Matchers

There are string, regular expression and header matchers. All can perform captures.

#### String

String matchers are very simple. They search through a whole field for a
specific substring. For instance: `'ID'` would match `Ticket ID`, `User ID`,
etc.

They can also perform named captures. `'%username%@example.org'` will match any
email address that ends with `@example.org`, and store the user part of the
address in a capture called `username`. Captures can be accessed by using
the `params` helper inside of blocks, or with block arguments (see below for
details).

The capture names may only contain letters and underscores. Behind the scenes
they are compiled to regular expressions, and each capture is the equivalent to
`.*`. There is currently no way to escape `%` characters. If a literal `%` is
required, and Mailman thinks it is a named capture, use a regular expression
matcher instead.

#### Regular expression

Regular expressions may be used as matchers. All captures will be available from the params helper (`params[:captures]`) as an Array, and as block arguments.

#### Headers

You can match against headers using strings or regular expressions. Multiple headers can be listed and all of them must be matched in order for the route to progress.

Capture groups are available for headers matched with regular expressions, although they are provided in a slightly more complex form, as some headers can appear multiple times.

For an email that looks like this:

```
To: hello@mailman.example.com
X-Forwarded-To: someone@example.com
X-Forwarded-To: other@example.in
```

You can expect the captures to work like this:

```ruby
Mailman::Application.run do
  header to: /h(ell)o/, x_forwarded_to: /(.+)@example.(.+)/ do
    p params[:captures]
    # => {
    #   to: [
    #     [ 'ell' ]
    #   ],
    #   x_forwarded_to: [
    #     [ 'someone', 'com' ],
    #     [ 'other', 'in' ]
    #   ]
    # }
  end
end
```

Using block arguments isn't advised for header matching as the exact number of arguments is limited only by the inbound email.

### Routes

Routes are defined within a Mailman application block:

```ruby
Mailman::Application.run do
  # routes here
end
```

Messages are passed through routes in the order they are defined in the
application from top to bottom. The first matching route's block will be
called.

#### Condition Chaining

Conditions can be chained so that the route will only be executed if all
conditions pass:

```ruby
to('support@example.org').subject(/urgent/) do
  # process urgent message here
end
```

#### Special routes

The `default` route is a catch-all that is run if no other routes match:

```ruby
default do
  # process non-matching messages
end
```

#### Block Arguments

All captures from matchers are available as block arguments:

```ruby
from('%user%@example.org').subject(/Ticket (\d+)/) do |username, ticket_id|
  puts "Got message from #{username} about Ticket #{ticket_id}"
end
```

#### Class Routing

Messages can also be routed to methods. For instance, to route to an
Object with a `receive` instance method defined, this will work:

```ruby
from '%user%@example.org', Sample
```

Messages can also be routed to arbitrary instance methods:

```ruby
from '%user%@example.org', 'ExampleClass#new_message'
```

The method should accept two arguments, the message object, and the params:

```ruby
def receive(message, params)
  # process message here
end
```

#### Route Helpers

There are two helpers available inside of route blocks:

The `params` hash holds all captures from matchers:

```ruby
from('%user%@example.org').subject(/RE: (.*)/) do
  params[:user] #=> 'chunkybacon'
  # it is an indifferent hash, so you can use strings and symbols
  # interchangeably as keys
  params['captures'][0] #=> 'A very important message about pigs'
end
```

The `message` helper is a `Mail::Message` object that contains the entire
message. See the [mail](http://github.com/mikel/mail/) docs for information on
the properties available.


### Conditions

Currently there are five conditions available: `to`, `from`, `cc`, `subject`, `body`

More can be added easily (see `lib/mailman/route/conditions.rb`).


## Receivers

There are currently three types of receivers in Mailman: Standard Input,
Maildir, and POP3. If IMAP or any complex setups are required, use a mail
retriever like [getmail](http://pyropus.ca/software/getmail/) with the
Maildir receiver.


### Standard Input

If a message is piped to a Mailman app, this receiver will override any
configured receivers. The app will process the message, and then quit. This
receiver is useful for testing and debugging. This feature can be disabled
with the `Mailman.config.ignore_stdin` option.

**Example**: `cat plain_message.eml | ruby mailman_app.rb`

*Note that the standard input receiver is not supported on Windows platforms.*

### POP3

The POP3 receiver is enabled when the `Mailman.config.pop3` hash is set. It
will poll every minute by default (this can be changed with
`Mailman.config.poll_interval`). After new messages are processed, they will
be deleted from the server. *No copy of messages will be saved anywhere
after processing*. If you want to keep a copy of messages, it is recommended
that you use a mail retriever with the Maildir receiver. You could also use
Gmail and set it to keep messages after they have been retrieved with POP3.

You can pass a Hash to `ssl` with
[SSL context options](http://www.ruby-doc.org/stdlib/libdoc/openssl/rdoc/OpenSSL/SSL/SSLContext.html).
For example, when you have a self-signed certificate: `ssl: { ca_file: '/etc/pki/my_ca.pem' }`.


### IMAP

The IMAP receiver is enabled when the `Mailman.config.imap` hash is set.
Polling can be set with `Mailman.config.poll_interval`. This will read all unread messages in the INBOX by default.
Here are example settings for gmail.

```ruby
Mailman.config.imap = {
  server: 'imap.gmail.com',
  port: 993, # you usually don't need to set this, but it's there if you need to
  ssl: true,
  # Use starttls instead of ssl (do not specify both)
  #starttls: true,
  username: 'foo@somedomain.com',
  password: 'totallyunsecuredpassword',
  move_seen: false, #if you want to move seen messages to another folder
  seen_folder: "PROCESSING"
}

```
* When using gmail, remember to [enable IMAP](https://support.google.com/mail/troubleshooter/1668960)
* You can pass a Hash to `ssl`, just like with POP3.

### HTTP

If `Mailman.config.http` is set then the HTTP receiver will be used. This will set up an HTTP server which expects emails to be delivered to `http://0.0.0.0:6245/` by default. You can alter the listening endpoint with the options below and altering the `parser` will allow different SMTP-HTTP gateways to be used.

**NB.** You will need to make sure `rack` (and optionally `thin`) are included in your gemset in order to use the HTTP receiver.

The default options are:

```ruby
Mailman.config.http = {
  host: '0.0.0.0',
  port: 6245,
  path: '/',
  parser: :raw_post,
  parser_opts: {
    part_name: 'message'
  }
}
```

#### Raw Post

The Raw Post Parser (`:raw_post`) expects the raw contents of emails to be delivered via multipart POST request to the specified endpoint. You can specify the name of the part which will contain the email data with the `:part_name` parser option ('message' by default).

The default HTTP configuration is perfect for [Cloudmailin](http://www.cloudmailin.com). If you set your target as `http://yourpublicserver:6245/` then mailman will work with the most basic config:

```ruby
Mailman.config.http = {}

Mailman::Application.run do
  # ... etc
end
```

#### Sendgrid

The parser for [Sendgrid](https://sendgrid.com) (`:sendgrid`) expects requests to conform to the [Inbound Parse Webhook](https://sendgrid.com/docs/API_Reference/Webhooks/parse.html) specification. Once you have pointed your domain's MX record at `mx.sendgrid.net` and configured an [inbound address](https://sendgrid.com/developer/reply) that points to your mailman server and the path you specified, all requests should flow as expected.

```ruby
Mailman.config.http = {
  parser: :sendgrid,
  path: "/emails"
}

Mailman::Application.run do
  # ... etc
end
```

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

```ruby
Mailman.config.pop3 = {
  :username => 'chunkybacon@gmail.com',
  :password => 'foobar',
  :server   => 'pop.gmail.com',
  :port     => 995, # you can usually omit this, but it's there
  :ssl      => true # defaults to false
}
```


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

**Default**: `'.'`

### Standard input receiver

`Mailman.config.ignore_stdin` disables the STDIN receiver, which can
interfere with running Mailman with cron or as a daemon.

**Default**: `false`

### Graceful death

`Mailman.config.graceful_death`, if set, will catch SIGINTs 
(Control-C) and allow the mail receiver to finish its current
iteration before exiting. Note that this currently only works
with POP3 receivers.

### Middleware

`Mailman.config.middleware` gives you access to the Mailman middleware stack.
Middleware allows you to execute code before and after each message is
processed. Middleware is super useful for things like error handling and any
other actions you need to do before/after each message is processed.

Here's an example of some simple error logging middleware:

```ruby
# Define the middleware
class ErrorLoggingMiddleware
  def call(mail)
    begin
      yield
    rescue
      puts "There was an error processing this message! #{mail.subject}"
      raise
    end
  end
end

# Add it to the Mailman middleware stack
Mailman.config.middleware.add ErrorLoggingMiddleware
```
