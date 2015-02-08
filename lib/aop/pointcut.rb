require "securerandom"

module Aop
  def self.[](pointcut_spec)
    Pointcut.new(pointcut_spec)
  end

  class Pointcut
    def initialize(spec)
      @spec = spec

      @class_spec = spec.scan(/^[^#\.]+/).first || ""
      @class_names = @class_spec.split(",")
      @classes = @class_names.map { |name| Object.const_get(name) }

      @method_spec = spec.scan(/[#\.][^#\.:]+/)
      @methods = @method_spec.map { |m| MethodReference.from(m) }

      @advices = spec.scan(/[^:]:([^:]+)/).flatten
    end

    def advice(&advised)
      advices = @advices
      advices.each do |advice|
        _advice(advice, advised)
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
          joint_point = lambda { result = method_ref.call(self, *args, &blk) }
          advised.call(joint_point, self, *args, &blk)
          result
        end
      end
    end

    class MethodReference
      def self.from(m)
        return new(m) if m[0...1] == "#"
        Singleton.new(m)
      end

      def initialize(m)
        @name = m[1..-1]
      end

      def decorate(target, &with)
        name = @name
        new_name = alias_name
        alias_target(target).class_eval do
          alias_method(new_name, name)
          define_method(name, &with)
        end
      end

      def call(target, *args, &blk)
        alias_target(target).send(alias_name, *args, &blk)
      end

      private

      def alias_target(target)
        target
      end

      def alias_name
        @_alias_name ||= "__aop_#{SecureRandom.hex(10)}"
      end

      class Singleton < self
        def alias_target(target)
          class << target; self; end
        end
      end
    end
  end
end
