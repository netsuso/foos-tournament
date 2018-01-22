# Reads a list of player_id + matches from stdin (one by line) and adds
# an entry for those players for the next round in their division

$LOAD_PATH << '..'

require 'season_repository'
require 'division_repository'
require 'player_repository'


season_repo = SeasonRepository.new()
division_repo = DivisionRepository.new()
player_repo = PlayerRepository.new()

current_season = season_repo.get_most_recent_season()
divisions = current_season.divisions
player_names = player_repo.get_all_players_by_id()

round_players = {}

ARGF.each do |line|
  line_data = line.split()
  player_id = line_data[0].to_i()
  matches = line_data[1].to_i()
  if !player_names.has_key?(player_id)
    puts "WARNING: Unknown player_id #{player_id}"
    next
  end
  round_players[player_id] = matches
end


divisions.each do |d|
  d.get_player_ids().each do |p|
    if round_players.has_key?(p)
      next_round = d.current_round + 1
      puts "Adding matches for player #{p} in division #{d.id} round #{next_round}"
      division_repo.add_round_player(d.id, p, next_round, matches)
    end
  end
end
