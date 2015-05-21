module Aop
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

    def method_name
      "#{method_notation}#{@name}"
    end

    private

    def method_spec(target)
      "#{target_name(target)}#{method_name}"
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
