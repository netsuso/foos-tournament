$LOAD_PATH << '..'

require 'division_repository'
require 'player_repository'
require 'match_assigner'
require 'match_repository'

if ARGV.length < 1
  puts "Syntax: generate_round <division_id>"
  exit
end

division_id = ARGV[0].to_i
round = ARGV[1].to_i

division_repo = DivisionRepository.new()
division = division_repo.get(division_id)

match_assigner = MatchAssigner.new()
solution = match_assigner.assign_matches(division)

match_repo = MatchRepository.new()
player_repo = PlayerRepository.new()
players_by_id = player_repo.get_all_players_by_id()

matches_to_add = []

nmatches = solution.length / 4
puts "Solution found with #{nmatches} matches:"
for m in 0...nmatches
  pl1 = solution[m*4]
  pl2 = solution[m*4+1]
  pl3 = solution[m*4+2]
  pl4 = solution[m*4+3]
  pl1name = players_by_id[pl1].name
  pl2name = players_by_id[pl2].name
  pl3name = players_by_id[pl3].name
  pl4name = players_by_id[pl4].name
  puts "%-16s%-16s%-16s%-16s" % [pl1name, pl2name, pl3name, pl4name]
  match = Match.new(nil, [pl1, pl2, pl3, pl4], division_id, round)
  matches_to_add << match
end

print "Press enter to confirm the assignments are valid: "
STDIN.gets

matches_to_add.each do |match|
  match_id = match_repo.add(match)
  puts "Added match with id #{match_id}"
end

puts "Updating division data..."
division_repo.update(division)
