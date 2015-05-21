module Aop
  class JointPoint
    def initialize(method_name, action)
      @method_name = method_name
      @action = action
    end

    def call(*args)
      @action.call(*args)
    end

    attr_reader :method_name
  end
end
