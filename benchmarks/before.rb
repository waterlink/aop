require "aop"
require "benchmark"
require "method_profiler"

class Example
  def normal_add(a, b)
    a + b
  end

  def heavy_add(a, b)
    a + b
  end
end

Aop["Example#heavy_add:before"].advice do |example, a, b|
  # do nothing
  nil
end

def benchmark
  example = Example.new

  Benchmark.bm 30 do |x|
    x.report 'normal add' do
      1000000.times do
        example.normal_add(rand(1000), rand(1000))
      end
    end

    x.report 'add with :before' do
      1000000.times do
        example.heavy_add(rand(1000), rand(1000))
      end
    end
  end
end

def profile
  example = Example.new

  observers = []
  observers << MethodProfiler.observe(Example)
  observers << MethodProfiler.observe(Aop)
  observers << MethodProfiler.observe(Aop::Pointcut)
  observers << MethodProfiler.observe(Aop::MethodReference)
  observers << MethodProfiler.observe(Aop::MethodReference::Singleton)

  10000.times do
    example.heavy_add(rand(1000), rand(1000))
  end

  observers.each { |o| puts o.report }
end

benchmark
profile
