class Season

attr_accessor :id
attr_reader :title
attr_reader :status
attr_reader :start_time
attr_reader :end_time
attr_reader :divisions

@divisions = []

def initialize(id, title)
  @id = id
  @title = title
end

def set_status(status, start_time, end_time)
  @status = status
  @start_time = start_time
  @end_time = end_time
end

def set_divisions(divisions)
  @divisions = divisions
end

end
