$LOAD_PATH << '..'

require 'division_repository'
require 'match_repository'
require 'hook_manager'

if ARGV.length == 0
  puts "Missing match id argument"
  exit
end

match_repo = MatchRepository.new()
division_repo = DivisionRepository.new()

match_id = ARGV[0].to_i
m = match_repo.get(match_id)
players = m.players

if m.played?
  puts "Cannot cancel a match that has already been played"
  exit(1)
end

division_id = m.division_id
d = division_repo.get(division_id)
planned_matches = d.planned_matches
assigned_matches = d.get_assigned_nmatches()

players.each do |player_id|
  new_planned = assigned_matches[player_id] - 1
  puts "Player #{player_id} has #{assigned_matches[player_id]} assigned matches and #{planned_matches[player_id]} planned. Resetting to #{new_planned}"
  planned_matches[player_id] = new_planned
end

puts "Updating division data..."
division_repo.update(d)

puts "Setting match as cancelled..."
m.set_status(1)
match_repo.update(m)

puts "Running hooks..."
HookManager.match_cancelled(match_id)
