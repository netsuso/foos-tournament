class Division

attr_accessor :id
attr_reader :level
attr_reader :name
attr_reader :scoring
attr_reader :total_rounds
attr_accessor :current_round
attr_reader :players
attr_reader :total_matches
attr_accessor :planned_matches
attr_reader :absences

@analysis_cache = nil

def initialize(id, level, name, scoring, total_rounds, current_round, players, total_matches, planned_matches, absences, matches)
  @id = id
  @level = level
  @name = name
  @scoring = scoring
  @total_rounds = total_rounds
  @current_round = current_round
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
  return @matches.select { |x| not x.played? }
end

def get_finished_matches()
  return @matches.select { |x| x.played? }
end

def get_round_matches(round)
  return @matches.select { |x| x.round == round }
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

def get_assigned_nmatches()
  nmatches = {}
  @players.each do |p|
    nmatches[p.id] = 0
  end
  @matches.each do |m|
    m.players.each do |p|
      nmatches[p] += 1
    end
  end
  return nmatches
end

def get_current_classification()
  return get_classification_history()[-1][:classification]
end

def get_classification_with_extra_match(extra_match)
  one2one, classification_history = analyse([extra_match])
  return classification_history[-1][:classification]
end

def get_one2one()
  return get_analysis()[0]
end

def get_classification_history()
  return get_analysis()[1]
end

private

def get_analysis()
  @analysis_cache = analyse() if not @analysis_cache
  return @analysis_cache
end

def analyse(extra_matches = [])
  one2one = {}
  classification_history = []
  current_classification = {}

  player_ids = get_player_ids()
  player_ids.each do |p|
    one2one[p] = {}
    (player_ids-[p]).each do |r|
      one2one[p][r] = {}
      one2one[p][r][:match_list] = []
      one2one[p][r][:nmatches] = 0
      one2one[p][r][:total_points] = 0
      one2one[p][r][:points] = -1
      one2one[p][r][:victories] = 0
      one2one[p][r][:defeats] = 0
      one2one[p][r][:goalsfor] = 0
      one2one[p][r][:goalsagainst] = 0
    end
    current_classification[p] = {
      :player_id => p,
      :points => 0,
      :num_rivals => 0,
      :num_matches => 0,
      :goals_for => 0,
      :goals_against => 0,
      :goal_average => 0
    }
  end

  classification_history << {:match => nil, :classification => current_classification.values}

  for m in @matches + extra_matches
    next if not m.played?
    classification = copy_current_classification(current_classification)
    analyse_match(m, one2one, classification)

    if @scoring == 0
      sorted_classification = classification.values.sort {|a, b| [b[:points], b[:goal_average], b[:goals_for]] <=> [a[:points], a[:goal_average], a[:goals_for]]}
    else
      sorted_classification = classification.values.sort {|a, b| b[:points] <=> a[:points]}
    end
    pos = 1
    sorted_classification.each do |c|
      c[:position] = pos
      pos += 1
    end

    classification_history << {:match => m, :classification => sorted_classification}
    current_classification = classification
  end

  return [one2one, classification_history]
end

def copy_current_classification(current_classification)
  new_classification = {}
  current_classification.each do |p, data|
    new_classification[p] = {
      :player_id => p,
      :points => data[:points],
      :num_rivals => data[:num_rivals],
      :num_matches => data[:num_matches],
      :goals_for => data[:goals_for],
      :goals_against => data[:goals_against],
      :goal_average => data[:goal_average]
    }
  end
  return new_classification
end

def analyse_match(match, one2one, classification)
  submatches = match.get_submatches()
  submatches.each do |team1, score1, team2, score2|
    team1.each do |p|
      team2.each do |r|
        one2one[p][r][:nmatches] += 1
        one2one[r][p][:nmatches] += 1
        one2one[p][r][:match_list] += [score1, score2]
        one2one[r][p][:match_list] += [score2, score1]
        one2one[p][r][:goalsfor] += score1
        one2one[r][p][:goalsfor] += score2
        one2one[p][r][:goalsagainst] += score2
        one2one[r][p][:goalsagainst] += score1
        if score1 > score2
          evaluate_match_score(one2one, p, r, score1, score2)
        else
          evaluate_match_score(one2one, r, p, score2, score1)
        end
      end
    end
  end

  match.players.each do |p|
    classification[p][:num_matches] += 1
    classification[p][:num_rivals] = 0
    classification[p][:total_points] = 0
    classification[p][:goals_for] = 0
    classification[p][:goals_against] = 0
    one2one[p].each do |r, data|
      if data[:nmatches] > 0
        classification[p][:num_rivals] += 1
        classification[p][:total_points] += data[:points]
        classification[p][:goals_for] += data[:goalsfor]
        classification[p][:goals_against] += data[:goalsagainst]
      end
    end
    if @scoring == 0
      classification[p][:points] = classification[p][:total_points]
    elsif (@scoring == 1 or @scoring == 2) and classification[p][:num_rivals] > 0
      classification[p][:points] = classification[p][:total_points] / classification[p][:num_rivals]
    end
    classification[p][:goal_average] = classification[p][:goals_for] - classification[p][:goals_against]
  end
end

def evaluate_match_score(one2one, p_winner, p_loser, score_winner, score_loser)
  if @scoring == 0
    one2one[p_winner][p_loser][:total_points] += 0.5
  elsif @scoring == 1
    one2one[p_winner][p_loser][:total_points] += 300
  elsif @scoring == 2
    one2one[p_winner][p_loser][:total_points] += 300 - score_loser*10
    one2one[p_loser][p_winner][:total_points] += score_loser*10
  end
  if @scoring == 0
    one2one[p_winner][p_loser][:points] = one2one[p_winner][p_loser][:total_points]
    one2one[p_loser][p_winner][:points] = one2one[p_loser][p_winner][:total_points]
  elsif @scoring == 1 or @scoring == 2
    one2one[p_winner][p_loser][:points] = one2one[p_winner][p_loser][:total_points].to_f / one2one[p_winner][p_loser][:nmatches]
    one2one[p_loser][p_winner][:points] = one2one[p_loser][p_winner][:total_points].to_f / one2one[p_loser][p_winner][:nmatches]
  end
end

end
