$LOAD_PATH << '.'

require 'dm/data_model'
require 'division_repository'
require 'season'

class SeasonRepository

@@status_map = {
  :preparing => 0,
  :playing => 1,
  :finished => 2,
}

public

def get(season_id)
  season_record = DataModel::Season.get(season_id)
  return map_record_to_entity(season_record)
end

def get_all_seasons()
  season_records = DataModel::Season.all()
  season_entities = []
  season_records.each do |s|
    season_entities << map_record_to_entity(s)
  end
  return season_entities
end

def get_most_recent_season()
  recent_seasons = DataModel::Season.all(:status => [1, 2], :order => [:status.asc, :end.desc, :start.desc])
  # FIXME: no seasons?
  return map_record_to_entity(recent_seasons[0])
end

def add(season_entity)
  season_record = DataModel::Season.new()
  season_record.title = season_entity.title
  season_record.status = @@status_map[season_entity.status]
  season_record.start = season_entity.start_time
  season_record.end = season_entity.end_time
  result = season_record.save
  # TODO: Raise exception on false result
  season_entity.id = season_record.id
  return season_record.id
end

private

def map_record_to_entity(season_record)
  season_entity = Season.new(season_record.id, season_record.title)
  entity_status = get_status_entity_value(season_record.status)
  season_entity.set_status(entity_status, season_record.start, season_record.end)

  division_repo = DivisionRepository.new()
  division_entities = division_repo.get_season_divisions(season_record.id)
  season_entity.set_divisions(division_entities)

  return season_entity
end

def get_status_entity_value(status)
  return @@status_map.detect {|k, v| v == status}[0]
end

end
