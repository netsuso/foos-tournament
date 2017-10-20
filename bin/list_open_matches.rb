$LOAD_PATH << '..'

require 'season_repository'
require 'division_repository'
require 'player_repository'

season_repo = SeasonRepository.new()
match_repo = MatchRepository.new()
player_repo = PlayerRepository.new()

current_season = season_repo.get_most_recent_season()
divisions = current_season.divisions
players = player_repo.get_all_players_by_id()

divisions.each do |d|
  open_matches = d.get_open_matches()
  open_matches.each do |m|
    nick1 = players[m.players[0]].nick
    nick2 = players[m.players[1]].nick
    nick3 = players[m.players[2]].nick
    nick4 = players[m.players[3]].nick
    puts "#{d.level}\t#{m.round}\t#{m.id}\t#{nick1}\t#{nick2}\t#{nick3}\t#{nick4}"
  end
end
