require 'benchmark'
require 'ostruct'

BENCHMARK_THREADS = 1
INVALIDATE_THREADS = 1

METHODS_COUNT = 100000

@invalidate = false

NAME = "#{BENCHMARK_THREADS}-#{INVALIDATE_THREADS}.csv"

class Dummy
  METHODS_COUNT.times do |i|
    define_method :"m#{i}" do
      rand.to_s
    end
  end
end

threads = []

benchmark_task = -> { METHODS_COUNT.times { |i| Dummy.new.public_send(:"m#{i}")} }

BENCHMARK_THREADS.times do |thread|
	threads << Thread.new do
    i = 0

		while true do
			a = Benchmark.measure { benchmark_task.call }

      File.open("t#{thread}-#{NAME}", 'a') { |f| f.write("#{a.total.to_s.gsub('.', ',')};#{thread}\n") }

      i += 1

      @invalidate = true if i > 200
		end
	end
end

INVALIDATE_THREADS.times do |thread|
  threads << Thread.new do
		while true do
      @invalidate ? OpenStruct.new(m: 1) : Dummy.new
		end
	end
end

threads.each(&:join)
