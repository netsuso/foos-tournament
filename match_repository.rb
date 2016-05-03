$LOAD_PATH << '.'

require 'dm/data_model'
require 'match'

class MatchRepository

public

def get(match_id)
  match_record = DataModel::Match.get(match_id)
  return map_record_to_entity(match_record)
end

def get_division_matches(division_id)
  match_records = DataModel::Match.all(DataModel::Match.division.id => division_id, :order => [:time.desc, :id.asc])
  return map_records_to_entities(match_records)
end

def get_recently_finished_matches(division_ids, limit)
  match_records = DataModel::Match.all(:division_id => division_ids, :played => true, :order => [:time.desc], :limit => limit)
  return map_records_to_entities(match_records)
end

def update(match_entity)
  match_id = match_entity.id
  match_record = DataModel::Match.get(match_id)
  map_entity_to_record(match_entity, match_record)
  match_record.save
end

def add(match_entity)
  match_record = DataModel::Match.new()
  map_entity_to_record(match_entity, match_record)
  match_record.save
  match_entity.id = match_record.id
  return match_record.id
end

private

def map_record_to_entity(m)
  players = [m.pl1, m.pl2, m.pl3, m.pl4]
  match_entity = Match.new(m.id,players, m.division_id, m.round)
  if m.played
    scores = [[m.score1a, m.score1b], [m.score2a, m.score2b], [m.score3a, m.score3b]]
    match_entity.set_scores(scores)
  end
  match_entity.set_played_status(m.played, m.time, m.duration)
  return match_entity
end

def map_records_to_entities(match_records)
  match_entities = []
  match_records.each do |m|
    match_entities << map_record_to_entity(m)
  end
  return match_entities
end

def map_entity_to_record(match_entity, match_record)
  match_record.division_id = match_entity.division_id
  match_record.round = match_entity.round
  match_record.played = match_entity.played
  players = match_entity.players
  match_record.pl1 = players[0]
  match_record.pl2 = players[1]
  match_record.pl3 = players[2]
  match_record.pl4 = players[3]
  if match_entity.played
    scores = match_entity.scores
    match_record.score1a = scores[0][0]
    match_record.score1b = scores[0][1]
    match_record.score2a = scores[1][0]
    match_record.score2b = scores[1][1]
    match_record.score3a = scores[2][0]
    match_record.score3b = scores[2][1]
    time = match_entity.time
    time = Time.now() if time == nil
    match_record.time = time
    match_record.duration = match_entity.duration
  end
end

end
