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

  (total_matches, planned_matches) = get_division_players_data(division_id)

  absences = get_player_absences(division_id)

  division_entity = Division.new(
    division_id,
    division_record.level,
    division_record.name,
    division_record.scoring,
    division_record.total_rounds,
    division_record.current_round,
    players,
    total_matches,
    planned_matches,
    absences,
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

def get_player_absences(division_id)
  absences = {}
  absence_records = DataModel::Absence.all(DataModel::Absence.division_id => division_id)
  absence_records.each do |a|
    absences[a.player_id] = [] if not absences.key?(a.player_id)
    absences[a.player_id] << a.round
  end
  return absences
end

def update_absences(division_id, new_absences_data)
  current_absence_records = DataModel::Absence.all(DataModel::Absence.division_id => division_id)

  # First detect existing records that no longer exist
  current_absence_records.each do |record|
    p = record.player_id
    if not new_absences_data.key?(p) or not new_absences_data[p].include?(record.round)
      record.destroy()
    else
      new_absences_data[p].delete(record.round)
    end
  end

  # Then create the newly added records
  new_absences_data.keys().each do |p|
    new_absences_data[p].each do |round|
      record = DataModel::Absence.new()
      record.division_id = division_id
      record.player_id = p
      record.round = round
      record.save()
    end
  end
end

private

def get_division_players_data(division_id)
  total_matches = {}
  planned_matches = {}
  division_players = DataModel::Divisionplayer.all(DataModel::Divisionplayer.division_id => division_id)
  division_players.each do |dp|
    total_matches[dp.player_id] = dp.total_matches
    planned_matches[dp.player_id] = dp.planned_matches
  end
  return [total_matches, planned_matches]
end

def map_entity_to_record(division_entity, division_record, divisionplayer_records)
  division_record.current_round = division_entity.current_round
  planned_matches = division_entity.planned_matches
  divisionplayer_records.each do |dp_record|
    player_id = dp_record.player_id
    dp_record.planned_matches = planned_matches[player_id]
  end
end

end
