module Mailman
  class Route

    CONDITIONS = [:to, :from, :subject, :body]

    CONDITIONS.each do |condition|
      class_eval <<-EOM
        def #{condition}(*args, &block)
          @#{condition} = args[0]
          if block_given?
            @block = block
            true
          else
            self
          end
        end
      EOM
    end

  end
end
