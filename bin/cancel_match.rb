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

puts "Setting match as cancelled..."
m.set_status(1)
match_repo.update(m)

puts "Running hooks..."
HookManager.match_cancelled(match_id)
