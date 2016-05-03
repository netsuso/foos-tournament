$LOAD_PATH << '..'

require 'match_repository'

def add_match(division_id, round, players)
end

if ARGV.length < 2
  puts "Syntax: add_round <division_id> <round_number>"
  exit 1
end

division_id = ARGV[0]
round = ARGV[1]

puts "Division #{division_id}, round #{round}"

match_repo = MatchRepository.new()

STDIN.each do |line|
  players = line.split()
  puts "Adding match with players #{players}"
  match = Match.new(nil, players, division_id, round)
  match_id = match_repo.add(match)
  puts "Match id is #{match_id}"
end

