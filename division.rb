class Division

attr_accessor :id
attr_reader :level
attr_reader :name
attr_reader :scoring
attr_reader :nrounds
attr_reader :players
attr_reader :total_matches
attr_reader :planned_matches
attr_reader :absences

@one2one = nil

def initialize(id, level, name, scoring, nrounds, players, total_matches, planned_matches, absences, matches)
  @id = id
  @level = level
  @name = name
  @scoring = scoring
  @nrounds = nrounds
  @players = players
  @total_matches = total_matches
  @planned_matches = planned_matches
  @absences = absences
  @matches = matches
end

def get_player_ids()
  return @players.map { |x| x.id }
end

def get_all_matches()
  return @matches
end

def get_open_matches()
  return @matches.select { |x| x.played == false }
end

def get_finished_matches()
  return @matches.select { |x| x.played == true }
end

def get_round_matches(round)
  return @matches.select { |x| x.round == round }
end

def analyse(extra_matches = [])
  one2one = {}
  one2one[:main] = {}
  player_ids = get_player_ids()
  player_ids.each do |p|
    one2one[:main][p] = {}
    (player_ids-[p]).each do |r|
      one2one[:main][p][r] = {}
      one2one[:main][p][r][:match_list] = []
      one2one[:main][p][r][:nmatches] = 0
      one2one[:main][p][r][:total_points] = 0
      one2one[:main][p][r][:victories] = 0
      one2one[:main][p][r][:defeats] = 0
      one2one[:main][p][r][:goalsfor] = 0
      one2one[:main][p][r][:goalsagainst] = 0
    end
  end

  for m in @matches + extra_matches
    next if not m.played
    submatches = m.get_submatches()
    submatches.each do |team1, score1, team2, score2|
      team1.each do |p|
        team2.each do |r|
          one2one[:main][p][r][:nmatches] += 1
          one2one[:main][r][p][:nmatches] += 1
          one2one[:main][p][r][:match_list] += [score1, score2]
          one2one[:main][r][p][:match_list] += [score2, score1]
          one2one[:main][p][r][:goalsfor] += score1
          one2one[:main][r][p][:goalsfor] += score2
          one2one[:main][p][r][:goalsagainst] += score2
          one2one[:main][r][p][:goalsagainst] += score1
          if score1 > score2
            one2one[:main][p][r][:victories] += 1
            one2one[:main][r][p][:defeats] += 1
            if @scoring == 2
              one2one[:main][p][r][:total_points] += 300 - score2*10
              one2one[:main][r][p][:total_points] += score2*10
            else
              one2one[:main][p][r][:total_points] += 300
            end
          else
            one2one[:main][p][r][:defeats] += 1
            one2one[:main][r][p][:victories] += 1
            if @scoring == 2
              one2one[:main][p][r][:total_points] += score1*10
              one2one[:main][r][p][:total_points] += 300 - score1*10
            else
              one2one[:main][r][p][:total_points] += 300
            end
          end
        end
      end
    end
    one2one[m.id] = Marshal.load(Marshal.dump(one2one[:main]))
  end

  player_ids.each do |p|
    (player_ids-[p]).each do |r|
      if one2one[:main][p][r][:nmatches] > 0
        one2one[:main][p][r][:points] = one2one[:main][p][r][:total_points].to_f / one2one[:main][p][r][:nmatches]
      else
        one2one[:main][p][r][:points] = -1
      end
    end
  end

  return one2one[:main]
end

def get_rivals_info()
  one2one = get_one2one()
  all_rivals = {}
  one2one.each do |p,data|
    rivals_data = []
    data.each do |r,info|
      rivals_data << [info[:points], info[:victories], info[:defeats], r]
    end
    all_rivals[p] = rivals_data.sort.reverse
  end
  return all_rivals
end

def get_classification(one2one = nil)
  one2one = get_one2one() if one2one == nil
  classification = []
  get_player_ids().each do |p|
    total_matches = 0
    total_points = 0
    nrivals = 0
    points = 0
    one2one[p].each do |r, data|
      if data[:nmatches] > 0
        nrivals += 1
        total_points += data[:points]
        total_matches += data[:nmatches]
      end
    end
    if nrivals > 0
      points = total_points / nrivals
    end
    classification << {:player_id => p, :points => points, :num_rivals => nrivals, :num_matches => total_matches/6}
  end
  classification = classification.sort {|a, b| b[:points] <=> a[:points]}
  pos = 1
  classification.each do |c|
    c[:position] = pos
    pos += 1
  end
  return classification
end

def get_round_absences(round)
  absent_players = {}
  @absences.each do |p, r|
    absent_players << p if r.key?(round)
  end
  return absent_players
end

def get_nmatches_per_player()
  nmatches = {}
  @players.each do |p|
    nmatches[p] = 0
  end
  for m in @matches
    submatches = m.get_submatches()
    submatches.each do |team1, score1, team2, score2|
      team1.each do |p|
        nmatches[p] += 1
      end
      team2.each do |p|
        nmatches[p] += 1
      end
    end
  end
  return nmatches
end

def get_pending_matches()
  pending_matches = {}

  played_matches = {}
  @players.each do |p|
    played_matches[p] = 0
  end
  for m in @matches
    submatches = m.get_submatches()
    submatches.each do |team1, score1, team2, score2|
      team1.each do |p|
        played_matches[p] += 1
      end
      team2.each do |p|
        played_matches[p] += 1
      end
    end
  end

  pending_rounds = @nrounds - round + 1
  @players.each do |p|
    pending_matches[p] = @total_matches[p] - played_matches[p]
  end

  return pending_matches
end

def get_classification_with_extra_match(extra_match)
  one2one = analyse([extra_match])
  return get_classification(one2one)
end

private

def get_one2one()
  return @one2one if @one2one
  @one2one = analyse()
  return @one2one
end


end
