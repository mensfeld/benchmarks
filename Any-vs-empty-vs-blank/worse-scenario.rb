require 'benchmark'

class Object
  def blank?
    respond_to?(:empty?) ? !!empty? : !self
  end

  def present?
    !blank?
  end
end


AMOUNT = 500_000_000
STEP = 1000

system "echo 'amount;empty;any;blank\n' > stats.csv"

(0...AMOUNT).step(STEP) do |size|
  GC.enable
  GC.start
  GC.disable

  ar = Array.new(size){ false }

  a = Benchmark.measure {
    ar.empty?
  }

  b = Benchmark.measure {
    ar.any?
  }

  c = Benchmark.measure {
    ar.blank?
  }

  #p a.real
  #p b.real
  #p c.real

  p size

  system "echo '#{size};#{a.real * 1000};#{b.real * 1000};#{c.real * 1000}' >> stats.csv"
end
