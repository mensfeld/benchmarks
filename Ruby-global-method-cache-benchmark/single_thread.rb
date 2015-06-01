require 'benchmark'
require 'ostruct'

class Dummy
  def m1
    rand.to_s
  end

  def m2
    rand.to_s
  end
end

benchmark_task = -> { rand(2) == 0 ? Dummy.new.m1 : Dummy.new.m2 }

i = 0

1000.times do
  res = Benchmark.measure {
    100000.times do
      OpenStruct.new(a: 1)
      benchmark_task.call
    end
  }.total

  p "#{res.to_s.gsub('.', ',')};#{i}"

  i += 1
end

