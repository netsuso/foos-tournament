class Match

attr_accessor :id 
attr_reader :division_id
attr_reader :round
attr_reader :players
attr_reader :scores
attr_reader :victories
attr_reader :played
attr_reader :time
attr_reader :duration

def initialize(id, players, division_id, round)
  @id = id
  @players = players
  @division_id = division_id
  @round = round

  @played = false
  @time = nil
  @duration = nil

  @scores = []
  @victories = []
end

def set_played_status(played, time, duration)
  @played = played
  @time = time
  @duration = duration
end

def set_scores(scores)
  @scores = scores
  calculate_victories()
end

def calculate_victories()
  @victories = [0, 0, 0, 0]
  if @scores[0][0] > @scores[0][1]
    @victories[0] += 1
    @victories[1] += 1
  else
    @victories[2] += 1
    @victories[3] += 1
  end
  if @scores[1][0] > @scores[1][1]
    @victories[0] += 1
    @victories[2] += 1
  else
    @victories[1] += 1
    @victories[3] += 1
  end
  if @scores[2][0] > @scores[2][1]
    @victories[0] += 1
    @victories[3] += 1
  else
    @victories[2] += 1
    @victories[1] += 1
  end
end

# FIXME: The human version should be generated in FE, not here
def get_time()
  return @time.strftime("%Y/%m/%d %H:%M")
end

# FIXME: The human version should be generated in FE, not here
def get_duration()
  if @duration
    duration_human = "%02d:%02d" % [@duration / 60, @duration % 60]
  else
    duration_human = "-"
  end
  return duration_human
end

def get_submatches()
  return [
    [[@players[0], @players[1]], @scores[0][0], [@players[2], @players[3]], @scores[0][1]],
    [[@players[0], @players[2]], @scores[1][0], [@players[1], @players[3]], @scores[1][1]],
    [[@players[0], @players[3]], @scores[2][0], [@players[1], @players[2]], @scores[2][1]]
  ]
end

end
