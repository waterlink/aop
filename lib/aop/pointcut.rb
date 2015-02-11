require "securerandom"

module Aop
  def self.[](pointcut_spec)
    Pointcut.new(pointcut_spec)
  end

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
      rescue NameError => err
        raise PointcutNotFound.new(method_spec(target), err)
      end

      def call(target, *args, &blk)
        target.send(alias_name, *args, &blk)
      end

      private

      def method_spec(target)
        "#{target_name(target)}#{method_notation}#{@name}"
      end

      def method_notation
        "#"
      end

      def alias_target(target)
        target
      end

      def target_name(target)
        target.name || target.inspect
      end

      def alias_name
        @_alias_name ||= :"__aop_#{SecureRandom.hex(10)}"
      end

      class Singleton < self
        def method_notation
          "."
        end

        def alias_target(target)
          class << target; self; end
        end
      end
    end
  end
end
