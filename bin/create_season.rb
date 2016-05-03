$LOAD_PATH << '..'

require 'season_repository'

if ARGV.length < 1
  puts "Syntax: create_season.rb <title>"
  exit
end

season_title = ARGV[0]

season_repo = SeasonRepository.new()
season = Season.new(nil, season_title)
season.set_status(:preparing, nil, nil)
season_repo.add(season)
