module Mailman
  class Route

    CONDITIONS = [:to, :from, :subject, :body]

    attr_reader :block, :conditions

    def initialize
      @conditions = []
    end

    CONDITIONS.each do |condition|
      class_eval <<-EOM
        def #{condition}(*args, &block)
          @conditions << :#{condition}
          @#{condition} = compile_condition(args[0])
          if block_given?
            @block = block
            true
          else
            self
          end
        end
      EOM
    end

    def compile_condition(condition)
      # Thanks Sinatra!
      keys = []
      if condition.respond_to?(:to_str)
        special_chars = %w{* . + ? \\ | ^ $ ( ) [ ] }
        pattern = condition.to_str.gsub(/((:\w+)|[\*\\.+?|^$()\[\]])/) do |match|
          case match
          when *special_chars
            Regexp.escape(match)
          else
            keys << $2[1..-1]
            "(.*)"
          end
        end
        [/#{pattern}/i, keys]
      elsif condition.respond_to?(:match)
        [condition, keys]
      end
    end

  end
end
