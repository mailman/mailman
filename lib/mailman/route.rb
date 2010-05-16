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
          @#{condition}_pattern, @#{condition}_params = compile_condition(args[0])
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
        special_chars = %w/* . + ? \\ | ^ $ ( ) [ ] { } /
        pattern = condition.to_str.gsub(/((:\w+)|[\*\\.+?|^$()\[\]{}])/) do |match|
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

    def match!(message)
      results = {}
      params = {}
      @conditions.each do |condition|
        results[condition] = method("match_#{condition}").call(message)
        if results[condition] && captures = results[condition].captures
          named_params = instance_variable_get("@#{condition}_params")
          params.merge! Hash[*named_params.zip(captures).flatten]
        end
      end

      if !results.value?(nil) and !results.values.empty?
        [@block, params]
      end
    end

    def match_to(message)
      message.to.each do |address|
        if result = @to_pattern.match(address)
          return result
        end
      end
      nil
    end

    def match_from(message)
      @from_pattern.match(message.from.first.to_s)
    end

  end
end
