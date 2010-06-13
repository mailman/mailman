module Mailman
  class Application

    attr_reader :router

    def initialize(&block)
      @router = Mailman::Router.new
      instance_eval(&block)
    end

  end
end
