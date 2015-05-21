%w[
  version

  errors
  pointcut
  joint_point
  method_reference
].each { |name| require "aop/#{name}" }

module Aop
  def self.[](pointcut_spec)
    Pointcut.new(pointcut_spec)
  end
end
