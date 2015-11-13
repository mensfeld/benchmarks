# frozen_string_literal: true
require 'benchmark'

GC.start
GC.disable

result = Benchmark.measure do
  10_000_000.times do
    'Ruby'
  end
end

puts result
