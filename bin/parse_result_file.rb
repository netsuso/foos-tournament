$LOAD_PATH << '..'

require 'json'
require 'result_processor'

if ARGV.length == 0
  puts "Missing file argument"
  exit
end

ARGV.each do |f|
  fd = open(f)
  result_data = JSON.load(fd)
  ResultProcessor.parse_result(result_data)
end
