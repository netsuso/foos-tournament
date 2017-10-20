# Reads a list of player_id from stdin (one by line) and adds an
# absence for those players for the next round in their division

$LOAD_PATH << '../foos-tournament'

require 'season_repository'
require 'division_repository'
require 'player_repository'


season_repo = SeasonRepository.new()
division_repo = DivisionRepository.new()
player_repo = PlayerRepository.new()

current_season = season_repo.get_most_recent_season()
divisions = current_season.divisions
player_names = player_repo.get_all_players_by_id()

absences = {}

ARGF.each do |line|
  player_id = line.strip().to_i()
  if !player_names.has_key?(player_id)
    puts "WARNING: Unknown player_id #{player_id}"
    next
  end
  absences[player_id] = true
end


divisions.each do |d|
  d.get_player_ids().each do |p|
    if absences.has_key?(p)
      next_round = d.current_round + 1
      puts "Adding absence for player #{p} in division #{d.id} round #{next_round}"
      division_repo.add_absence(d.id, p, next_round)
    end
  end
end
