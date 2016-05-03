$LOAD_PATH << '.'

require 'dm/data_model'
require 'player'

class PlayerRepository

public

def get_all_players_by_id()
  player_records = DataModel::Player.all()
  players_by_id = {}
  player_records.each do |p|
    player_entity = Player.new(p.id, p.name, p.email, p.frequency, p.extra)
    players_by_id[p.id] = player_entity
  end
  return players_by_id
end

def get_division_players(division_id)
  player_records = DataModel::Player.all(DataModel::Player.divisions.id => division_id)
  return map_records_to_entities(player_records)
end

# TODO
def assign_player(division_id, player_id)
  Divisionplayer.create(Divisionplayer.division.id => division_id, Divisionplayer.player.id => player_id)
end

# TODO
def add()
  p = Player.create(:name => name, :email => email, :frequency => frequency)
end

private

def map_records_to_entities(player_records)
  player_entities = []
  player_records.each do |p|
    player_entity = Player.new(p.id, p.name, p.email, p.frequency, p.extra)
    player_entities << player_entity
  end
end

end
