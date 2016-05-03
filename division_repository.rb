$LOAD_PATH << '.'

require 'dm/data_model'
require 'division'
require 'match_repository'
require 'player_repository'

class DivisionRepository

public

def get(division_id)
  division_record = DataModel::Division.get(division_id)

  player_repo = PlayerRepository.new()
  players = player_repo.get_division_players(division_id)

  match_repo = MatchRepository.new()
  matches = match_repo.get_division_matches(division_id)

  division_entity = Division.new(
    division_id,
    division_record.level,
    division_record.name,
    division_record.scoring,
    players,
    matches
  )
  return division_entity
end

def get_season_divisions(season_id)
  division_entities = []
  division_records = DataModel::Division.all(:season_id => season_id)
  division_records.each do |d|
    # FIXME: Unify with get()
    player_repo = PlayerRepository.new()
    players = player_repo.get_division_players(d.id)

    match_repo = MatchRepository.new()
    matches = match_repo.get_division_matches(d.id)

    division_entity = Division.new(
      d.id,
      d.level,
      d.name,
      d.scoring,
      players,
      matches
    )
    division_entities << division_entity
  end
  return division_entities
end

def add(division_entity)
  division_record = DataModel::Division.new()
  division_record.name = season_entity.name
  division_record.level = season_entity.level
  division_record.scoring = season_entity.scoring
  division_record.save
  division_entity.id = division_record.id
  return division_record.id
end

end
