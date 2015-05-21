module Aop
  class PointcutNotFound < StandardError
    attr_reader :original_error

    def initialize(pointcut_spec, original_error)
      super("Unable to find pointcut #{pointcut_spec}")
      @original_error = original_error
    end

    def to_s
      "#{super}\n\tReason: #{original_error.inspect}"
    end
  end
end
