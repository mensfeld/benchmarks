ITERATIONS = (1..100)
TEMPLATE = 'dynamic-nested-blocks_benchmark_template.rb'
TMP_EXEC = 'dynamic_test.rb'

template = File.read(TEMPLATE)

ITERATIONS.to_a.each do |i|
  std_code = ''

  i.times do |j|
    std_code << "around#{j} = AroundFilterWrapper.new\n"
  end

  i.times do |j|
    std_code << "around#{j}.monitor do\n"
  end

  std_code << "ExampleClass.new.execute\n"

  i.times do |j|
    std_code << "end\n"
  end

  tmp = template.dup
  tmp.gsub!('TIMES', i.to_s)
  tmp.gsub!('STD_AROUND', std_code)

  File.open(TMP_EXEC, 'w') { |file| file.write(tmp) }

  res = `ruby #{TMP_EXEC}`
  p res.split("\n")[8]
  p res.split("\n")[9]
end
