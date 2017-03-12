$LOAD_PATH << '.'

require 'match_solver'

class MatchAssigner

@@debug = false

def assign_matches(division)
  total_rounds = division.total_rounds
  current_round = division.current_round
  total_matches = division.total_matches
  planned_matches = division.planned_matches
  assigned_matches = division.get_assigned_nmatches()
  absences = division.absences

  to_play = {}
  total_rivals = 0
  adjustment_add = []
  adjustment_remove = []

  current_round = 0 if current_round == nil

  if current_round >= total_rounds
    raise 'All rounds have already been generated for this division'
  end

  current_round += 1
  division.current_round = current_round

  puts "Round #{current_round}/#{total_rounds}"

  max_to_play = 0
  absents = []
  total_matches.keys().each do |p|
    future_absences = 0
    if absences.key?(p)
      if absences[p].include?(current_round)
        puts "Player %3d: ABSENT" % p
        to_play[p] = 0
        absents << p
        next
      end
      future_absences = absences[p].count { |x| x > current_round }
    end
    pending_rounds = total_rounds - current_round+1 - future_absences
    matches_per_round = (total_matches[p] - planned_matches[p]) / pending_rounds
    old_planned = planned_matches[p]
    planned_matches[p] += matches_per_round

    target = planned_matches[p].round()
    to_play[p] = target - assigned_matches[p]
    max_to_play = to_play[p] if to_play[p] > max_to_play
    total_rivals += to_play[p]

    puts "Player %3d: %2d rounds - %2d total - %5.2f (%2d) -> %5.2f (%2d) = %d to play" % [p, pending_rounds, total_matches[p], old_planned, assigned_matches[p], planned_matches[p], target, to_play[p]]
  end

  while true
    total_matches_to_play = (total_rivals/4).floor()
    if max_to_play > total_matches_to_play
	  to_play.keys().each do |p|
        if to_play[p] > total_matches_to_play
          removed = to_play[p] - total_matches_to_play
          puts "Too many matches for player %d (%d for a total of %d matches), removing %d" % [p, to_play[p], total_matches_to_play, removed]
          to_play[p] -= removed
          total_rivals -= removed
        end
        max_to_play = total_matches_to_play
      end
    else
      break
    end
  end

  total_matches.keys().each do |p|
    next if absents.include?(p)

    damage_remove = 0.5 + planned_matches[p] - (assigned_matches[p] + to_play[p])
    damage_add = 1 - damage_remove

    penalty_nmatches = 0.25 * total_rounds / total_matches[p]

    adjustment_remove << { :player => p, :damage => damage_remove, :sort_value => [damage_remove + penalty_nmatches, -to_play[p], rand()] }
    adjustment_add << { :player => p, :damage => damage_add, :sort_value => [damage_add + penalty_nmatches, to_play[p], rand()] }
  end

  uncomplete = total_rivals % 4
  if uncomplete != 0
    to_remove = uncomplete
    to_add = 4 - uncomplete
    puts "There are #{uncomplete} extra players (total #{total_rivals}), we need to add #{to_add} or remove #{to_remove}"

    sorted_adjustment_add = adjustment_add.sort { |a, b| a[:sort_value] <=> b[:sort_value] }
    sorted_adjustment_remove = adjustment_remove.sort { |a, b| a[:sort_value] <=> b[:sort_value] }
    total_damage_add = sorted_adjustment_add[0...to_add].inject(0) { |sum, x| sum + x[:damage] }
    total_damage_remove = sorted_adjustment_remove[0...to_remove].inject(0) { |sum, x| sum + x[:damage] }

    puts "Adding #{to_add} players would have a damage of #{total_damage_add}"
    puts sorted_adjustment_add
    puts "Removing #{to_remove} players would have a damage of #{total_damage_remove}"
    puts sorted_adjustment_remove

    if total_damage_add <= total_damage_remove or current_round == total_rounds
      sorted_adjustment_add[0...to_add].each do |pd|
        p = pd[:player]
        puts "Adding match to player " + p.to_s
        to_play[p] += 1
      end
    else
      sorted_adjustment_remove[0...to_remove].each do |pd|
        p = pd[:player]
        puts "Removing match to player " + p.to_s
        to_play[p] -= 1
      end
    end
  end

  puts "Matches to be played by player:"
  puts to_play

  players_to_play = []
  to_play.each do |p, tp|
    players_to_play += [p] * tp
  end

  nrivals = players_to_play.length
  if nrivals == 0
    puts "No pending matches to play for any player" if @@debug
    return []
  end
  puts players_to_play if @@debug

  one2one = fill_basic_one2one(division.players)
  matches = division.get_assigned_matches()
  fill_one2one_with_matches(one2one, matches)

  begin
    solver = Solver.new(one2one)
    solution, score, new_one2one = solver.solve(players_to_play)
    puts "Found solution with score #{score}"
  rescue Exception => e
    puts e
    puts "No valid solution could be achieved for these players"
    solution = []
  end

  return solution
end

def fill_basic_one2one(players)
  one2one = {}
  for p in players
    one2one[p.id] = {}
    for q in players - [p]
      one2one[p.id][q.id] = 0
    end
  end
  one2one
end

def fill_one2one_with_solution(one2one, solution)
  nmatches = solution.length / 4
  for m in 0...nmatches
    pl1 = solution[m*4]
    pl2 = solution[m*4+1]
    pl3 = solution[m*4+2]
    pl4 = solution[m*4+3]
    #puts "Analysing match with #{pl1}, #{pl2}, #{pl3}, #{pl4}"
    one2one[pl1][pl2] += 1
    one2one[pl1][pl3] += 1
    one2one[pl1][pl4] += 1
    one2one[pl2][pl1] += 1
    one2one[pl2][pl3] += 1
    one2one[pl2][pl4] += 1
    one2one[pl3][pl1] += 1
    one2one[pl3][pl2] += 1
    one2one[pl3][pl4] += 1
    one2one[pl4][pl1] += 1
    one2one[pl4][pl2] += 1
    one2one[pl4][pl3] += 1
  end
end

def fill_one2one_with_matches(one2one, matches)
  for m in matches
    solution = m.players
    fill_one2one_with_solution(one2one, solution)
  end
end

end
