module Mailman
  class Route

    attr_reader :block, :conditions

    def initialize
      @conditions = []
    end

    def match!(message)
      params = {}
      args = []
      @conditions.each do |condition|
        if result = condition.match(message)
          params.merge!(result[0])
          args += result[1]
        else
          return nil
        end
      end
      [@block, params, args]
    end

  end
end
