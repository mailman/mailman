module Mailman
  class Middleware
    attr_reader :entries

    def initialize
      @entries = []
      yield self if block_given?
    end

    def add(klass)
      entries << klass
    end

    def remove(klass)
      entries.delete(klass)
    end

    def insert_before(oldklass, newklass)
      idx = entries.index(oldklass) || 0
      entries.insert(idx, newklass)
    end

    def insert_after(oldklass, newklass)
      idx = entries.rindex(oldklass) || entries.count - 1
      entries.insert(idx+1, newklass)
    end

    def run(*args, &final_action)
      final_return = nil
      stack = @entries.map {|m| m.new}
      traverse_stack = lambda do
        if stack.empty?
          final_return = final_action.call
        else
          stack.shift.call(*args, &traverse_stack)
        end
      end
      traverse_stack.call

      final_return
    end

    def each(&block)
      entries.each(&block)
    end
  end
end