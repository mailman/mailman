require 'rack'
require 'uri'

module Mailman
  module Receiver
    # Receives messages over HTTP, and passes them to a {MessageProcessor}.
    #
    # If using CloudMailIn (Raw format) you would make your target "http://yourserver:6245/" and use this code:
    #
    #     Mailman.config.http = {
    #       host: '0.0.0.0',
    #       port: 6245,
    #       path: '/',
    #       parser: :raw_post,
    #       parser_opts: {
    #         part_name: 'message'
    #       }
    #     }
    #
    #     Mailman::Application.run do
    #       # ... etc
    #     end
    #
    # However those are all the defaults, so you could also just use:
    #
    #     Mailman.config.http = {}
    #
    #     Mailman::Application.run do
    #       # ... etc
    #     end
    #
    # Sendgrid format is also available, which is simply:
    #
    #     Mailman.config.http = { parser: :sendgrid }
    #
    #     Mailman::Application.run do
    #       # ... etc
    #     end
    class HTTP

      # @param [Hash] options the receiver options
      # @option options [MessageProcessor] :processor the processor to pass new
      #   messages to
      # @option options [String] :host ('0.0.0.0') The host the server should listen on
      # @option options [Integer] :port (6245) The port the server should listen on
      # @option options [String] :path ('/') The path that should trigger email delivery
      # @option options [Symbol] :handler (:thin, :webrick) The rack server to use. Falls back on thin, then webrick.
      # @option options [Symbol] :parser (:raw_post) The parser which should be used to extract the email content from the HTTP request.
      # @option options [Symbol] :parser_opts ({}) Options to be passed to the parser.
      def initialize(options)
        @processor = options[:processor]
        @listen = URI::HTTP.build(
          host: options[:host] || "0.0.0.0",
          port: options[:port] || 6245,
          path: options[:path] || "/"
        )

        options[:parser] ||= :raw_post
        parser_klass = "#{options[:parser].to_s.camelize}Parser"
        begin
          @parser = Mailman::Receiver::HTTP.const_get(parser_klass).new(options[:parser_opts] || {})
        rescue NameError
          raise "The Mailman::Receiver::HTTP::#{parser_klass} parser isn't defined."
        end

        @handler = Rack::Handler.pick([options[:handler], :thin, :webrick].compact)
      end

      # Starts the HTTP server
      def start_and_block
        @handler.run(self, {:Host => @listen.host, :Port => @listen.port}) do |server|
          Mailman.logger.info "Listening for emails at #{@listen} using #{@parser.class.name.demodulize} processing"
        end
      end

      ## Web server components

      def call(env)
        return [404, {}, []] if env['REQUEST_PATH'] != @listen.path
        begin
          @processor.process(@parser.parse(env))
          return [200, {}, []]
        rescue Exception => e
          Mailman.logger.error(e.message + "\n#{e.backtrace}")
          return [500, {}, ["Email processing failed"]]
        end
      end

      # A class which abstracts the processing of CloudMailIn style 'Raw' emails over HTTP. To use:
      #
      #      Mailman.config.http = {
      #        parser: :raw_post,
      #        parser_opts: {
      #          part_name: 'message' 
      #        }
      #      }
      class RawPostParser
        # @param [Hash] opts The parser's options
        # @option opts [String] :part_name ('message') The name of the mulipart segment which will contain the email
        def initialize(opts = {})
          @opts = opts
          @opts['part_name'] ||= 'message'
        end

        # Parses a Rack `env` variable and creates a +Mail::Message+ from the email contents found.
        def parse(env)
          multipart = Rack::Multipart.parse_multipart(env)
          Mail.new(multipart[@opts['part_name']])
        end
      end

      # A class which abstracts the processing of SendGrid style emails over HTTP. To use:
      #
      #      Mailman.config.http = { parser: :sendgrid }
      class SendgridParser
        # @param [Hash] opts The parser's options - not used for this parser.
        def initialize(opts = {}); end

        # Parses a Rack `env` variable and creates a +Mail::Message+ from the email contents found.
        def parse(env)
          parts = Rack::Multipart.parse_multipart(env)
          Mail.new do
            header parts['headers']
            text_part { parts['text'] }
            html_part { parts['html'] }
          end
        end
      end
    end
  end
end
