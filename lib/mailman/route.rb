module Mailman
  class Route

    attr_reader :block, :conditions

    def initialize
      @conditions = []
    end

  end
end
