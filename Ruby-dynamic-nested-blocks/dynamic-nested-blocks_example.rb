require 'ruby-prof'
GC.disable
ITERATIONS = 10_000

class TimeBenchmarkWrapper
  def monitor
    time = Time.now
    yield
    ms = (Time.now - time) * 1000
    "#{TimeBenchmarkWrapper}: Time taken: #{ms}ms\n"
  end
end

class LoggerWrapper
  def monitor
    "#{LoggerWrapper}: logging something\n"
    yield
  end
end

class AroundFilterWrapper
  def monitor
    before_action
    yield
    after_action
  end

  def before_action
    "#{AroundFilterWrapper} before logic\n"
  end

  def after_action
    "#{AroundFilterWrapper} after logic\n"
  end
end

class ExampleClass
  def execute
    # Here should the code go
    "#{ExampleClass} executing...\n"
  end
end

RubyProf.start

time = TimeBenchmarkWrapper.new
logger = LoggerWrapper.new
around = AroundFilterWrapper.new

ITERATIONS.times do
  around.monitor do
    logger.monitor do
      time.monitor do
        ExampleClass.new.execute
      end
    end
  end
end

result = RubyProf.stop
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)

def wrap_with(wrappers, &block)
  # We define the most bottom block - that should evaluate the real code
  # All the blocks are in array because we will use inject to inject one into another
  # and since we will be injecting first into second, second into third, etc
  # our "base" proc needs to be first (it will be the most inner block)
  blocks = [-> { block.call } ]

  # Each wrapper needs to be wrapped with a proc that accepts a inner block containing
  # stuff that should be inside - this inside stuff is a proc as well and
  # will be executed. That's why when we execute the most outer block if will execute
  # the inner one (and it will happen as a cascade)
  blocks += wrappers.map do |wrapper|
    proc do |inner_block = nil|
      wrapper.new.monitor do
        inner_block.call
      end
    end
  end

  # In general it is equal to a code like this (but generated dynamically):
  # We assume that we have following monitors: [Monitor1, Monitor2, Monitor3]
  # Monitor3.new.monitor do
  #   Monitor2.new.monitor do
  #     Monitor1.new.monitor do
  #       proxy.call(*args, &block)
  #     end
  #   end
  # end
  blocks.inject do |inner, resource|
    proc { resource.call(inner) }
  end.call
end

wrappers = [TimeBenchmarkWrapper, LoggerWrapper, AroundFilterWrapper]

RubyProf.start

ITERATIONS.times do
  wrap_with(wrappers) do
    ExampleClass.new.execute
  end
end

result = RubyProf.stop
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)
