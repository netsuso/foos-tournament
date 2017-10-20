class Player

attr_accessor :id
attr_reader :name
attr_reader :nick

def initialize(id, name, nick)
  @id = id
  @name = name
  @nick = nick
end

end
