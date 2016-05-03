$LOAD_PATH << '..'

require 'division_repository'
require 'player_repository'
require 'match_assigner'

if ARGV.length < 2
  puts "Syntax: calculate_next_matches <division_id> <num_round>"
  exit
end

division_id = ARGV[0].to_i
round = ARGV[1].to_i

division_repo = DivisionRepository.new()
division = division_repo.get(division_id)

match_assigner = MatchAssigner.new(division, round)
best_solution = match_assigner.assign_matches()

player_repo = PlayerRepository.new()
players_by_id = player_repo.get_all_players_by_id()

nmatches = best_solution.length / 4
for m in 0...nmatches
  pl1 = best_solution[m*4]
  pl2 = best_solution[m*4+1]
  pl3 = best_solution[m*4+2]
  pl4 = best_solution[m*4+3]
  puts "#{pl1}\t#{pl2}\t#{pl3}\t#{pl4}"
end
for m in 0...nmatches
  pl1 = best_solution[m*4]
  pl2 = best_solution[m*4+1]
  pl3 = best_solution[m*4+2]
  pl4 = best_solution[m*4+3]
  pl1name = players_by_id[pl1].name
  pl2name = players_by_id[pl2].name
  pl3name = players_by_id[pl3].name
  pl4name = players_by_id[pl4].name
  puts "#{pl1name}\t#{pl2name}\t#{pl3name}\t#{pl4name}"
end

#puts best_one2one
