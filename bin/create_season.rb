$LOAD_PATH << '..'

require 'season_repository'

if ARGV.length < 1
  puts "Syntax: create_season.rb <title> [--active|-a]"
  exit
end

season_title = ARGV[0]
season_status = (ARGV.length > 1 and ['--active', '-a'].include?(ARGV[1])) ?
  :playing :
  :preparing

season_repo = SeasonRepository.new()
season = Season.new(nil, season_title)
season.set_status(season_status, nil, nil)
season_repo.add(season)
