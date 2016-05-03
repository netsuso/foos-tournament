$LOAD_PATH << '..'

require 'division_repository'

if ARGV.length == 0
  puts "Missing division id"
  exit
end

division_id = ARGV[0]

division_repo = DivisionRepository.new()
division = division_repo.get(division_id)

player_repo = PlayerRepository.new()
players = player_repo.get_all_players_by_id()

classification = division.get_classification()

classification.each do |c|
  player_name = players[c[:player_id]].name
  puts "#{c[:position]}\t#{player_name}\t#{c[:points]}\t#{c[:num_rivals]}\t#{c[:num_matches]}"
end

rivals = division.get_rivals_info()

rivals.each do |p, rivals_data|
  player_name = players[p].name
  rivals_data = rivals_data.sort.reverse

  rivals_data.each do |points, victories, defeats, rival_id|
    rival_name = players[rival_id].name
    if points == -1
      puts "#{player_name} vs #{rival_name}: no matches yet"
    else
      puts "#{player_name} vs #{rival_name}: #{points} (#{victories}-#{defeats})"
    end
  end

end
