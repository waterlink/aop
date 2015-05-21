require "securerandom"

module Aop
  class Pointcut
    def initialize(spec)
      @spec = spec

      @class_spec = spec.scan(/^[^#\.]+/).first || ""
      @class_names = @class_spec.split(",")
      @classes = @class_names.map do |name|
        begin
          Object.const_get(name)
        rescue NameError => err
          raise PointcutNotFound.new(spec, err)
        end
      end

      @method_spec = spec.scan(/[#\.][^,#\.:]+/)
      @methods = @method_spec.map { |m| MethodReference.from(m) }

      @advices = spec.scan(/[^:]:([^:,]+)/).flatten
    end

    def advice(&advised)
      return _advice(@advices.first, advised) if @advices.count == 1
      @advices.each do |advice|
        Aop["#{@class_names.join(",")}#{@method_spec.join(",")}:#{advice}"].advice(&advised)
      end
    end

    private

    def _advice(advice, advised)
      return before_advice(advised) if advice == "before"
      return around_advice(advised) if advice == "around"
      after_advice(advised)
    end

    def generic_advice(advised, &body)
      methods = @methods
      @classes.each do |klass|
        klass.class_eval do
          methods.each do |method_ref|
            method_ref.decorate(klass, &body[method_ref])
          end
        end
      end
    end

    def before_advice(advised)
      generic_advice(advised) do |method_ref|
        lambda do |*args, &blk|
          advised.call(self, *args, &blk)
          method_ref.call(self, *args, &blk)
        end
      end
    end

    def after_advice(advised)
      generic_advice(advised) do |method_ref|
        lambda do |*args, &blk|
          result = method_ref.call(self, *args, &blk)
          advised.call(self, *args, &blk)
          result
        end
      end
    end

    def around_advice(advised)
      generic_advice(advised) do |method_ref|
        lambda do |*args, &blk|
          result = nil
          joint_point = JointPoint.new(
            method_ref.method_name,
            lambda { result = method_ref.call(self, *args, &blk) }
          )
          advised.call(joint_point, self, *args, &blk)
          result
        end
      end
    end
  end
end
