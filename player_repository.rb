$LOAD_PATH << '.'

require 'dm/data_model'
require 'player'

class PlayerRepository

public

def get(player_id)
  player_record = DataModel::Player.get(player_id)
  return map_record_to_entity(player_record)
end

def get_all_players()
  player_records = DataModel::Player.all()
  player_entities = []
  player_records.each do |p|
    player_entities << map_record_to_entity(p)
  end
  return player_entities
end

def get_all_players_by_id()
  player_records = DataModel::Player.all()
  players_by_id = {}
  player_records.each do |p|
    players_by_id[p.id] = map_record_to_entity(p)
  end
  return players_by_id
end

def get_division_players(division_id)
  player_records = DataModel::Player.all(DataModel::Player.divisions.id => division_id)
  player_entities = []
  player_records.each do |p|
    player_entities << map_record_to_entity(p)
  end
  return player_entities
end

# TODO
def assign_player(division_id, player_id, nmatches)
  Divisionplayer.create(Divisionplayer.division.id => division_id, Divisionplayer.player.id => player_id)
end

def add(player_entity)
  player_record = DataModel::Player.new()
  player_record.name = player_entity.name
  player_record.email = player_entity.email
  player_record.save
  player_entity.id = player_record.id
  return player_record.id
end

private

def map_record_to_entity(player_record)
  player_entity = Player.new(player_record.id, player_record.name, player_record.email)
end

end
