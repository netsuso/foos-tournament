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

  (total_matches, assign_deviation) = get_division_players_data(division_id)

  round_players = get_round_players(division_id)

  division_entity = Division.new(
    division_id,
    division_record.level,
    division_record.name,
    division_record.scoring,
    division_record.total_rounds,
    division_record.current_round,
    players,
    total_matches,
    assign_deviation,
    round_players,
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
      d.total_rounds,
      d.current_round,
      players,
      [],
      [],
      [],
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
  division_record.save()
  division_entity.id = division_record.id
  return division_record.id
end

def update(division_entity)
  division_id = division_entity.id
  division_record = DataModel::Division.get(division_id)
  divisionplayer_records = DataModel::Divisionplayer.all(DataModel::Divisionplayer.division_id => division_id)

  map_entity_to_record(division_entity, division_record, divisionplayer_records)

  division_record.save()
  divisionplayer_records.each do |dp_record|
    dp_record.save()
  end
end

def get_round_players(division_id)
  round_players = {}
  round_players_records = DataModel::Roundplayer.all(DataModel::Roundplayer.division_id => division_id)
  round_players_records.each do |a|
    round_players[a.round] = {} if not round_players.key?(a.round)
    round_players[a.round][a.player_id] = a.matches
  end
  return round_players
end

def add_round_player(division_id, player_id, round, matches)
  record = DataModel::Roundplayer.new()
  record.division_id = division_id
  record.player_id = player_id
  record.round = round
  record.matches = matches
  record.save()
end

private

def get_division_players_data(division_id)
  total_matches = {}
  assign_deviation = {}
  division_players = DataModel::Divisionplayer.all(DataModel::Divisionplayer.division_id => division_id)
  division_players.each do |dp|
    total_matches[dp.player_id] = dp.total_matches
    assign_deviation[dp.player_id] = dp.assign_deviation
  end
  return [total_matches, assign_deviation]
end

def map_entity_to_record(division_entity, division_record, divisionplayer_records)
  division_record.current_round = division_entity.current_round
  assign_deviation = division_entity.assign_deviation
  divisionplayer_records.each do |dp_record|
    player_id = dp_record.player_id
    dp_record.assign_deviation = assign_deviation[player_id]
  end
end

end
