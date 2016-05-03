class Player

attr_reader :id
attr_reader :name
attr_reader :email
attr_reader :frequency
attr_reader :extra

def initialize(id, name, email, frequency, extra)
  @id = id
  @name = name
  @email = email
  @frequency = frequency
  @extra = extra
end

end
