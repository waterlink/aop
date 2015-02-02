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
      methods = @methods
      @classes.each do |klass|
        klass.class_eval do
          methods.each do |method_ref|
            method_ref.decorate(klass) do |*args, &blk|
              advised.call(self, *args, &blk)
              method_ref.call(self, *args, &blk)
            end
          end
        end
      end
    end

    class MethodReference
      def self.from(m)
        return new(m) if m[0] == "#"
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
