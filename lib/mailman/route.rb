module Mailman
  class Route

    CONDITIONS = [:to, :from, :subject, :body]

    CONDITIONS.each do |condition|
      class_eval <<-EOM
        def #{condition}(*args, &block)
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
      keys = []
      special_chars = %w{* . + ? \\ | ^ $ ( ) [ ] }
      pattern = condition.gsub(/((:\w+)|[\*\\.+?|^$()\[\]])/) do |match|
        case match
        when *special_chars
          Regexp.escape(match)
        else
          keys << $2[1..-1]
          "(.*)"
        end
      end
      [/#{pattern}/i, keys]
    end

  end
end
