require 'csv'

GC.start
GC.disable

ITERATIONS = (1..100)

FILES = [
  'performance/frozen.rb',
  'performance/not-frozen.rb'
]

rows = [
  [],
  []
]

FILES.each_with_index do |file, index|
  ITERATIONS.to_a.each do |i|
    std_code = ''
    res = `ruby #{file}`
    rows[index] << res.split('(  ').last.gsub(")\n", '').to_f.to_s.gsub('.', ',')
  end
end

CSV.open("performance.csv", "wb") do |csv|
  (rows.flatten.count / 2).times do |i|
    csv << [rows[0][i], rows[1][i]]
  end
end
