require 'net/http'

module HookManager

def self.match_played(match_id)
  hooks = Conf.settings.hooks['match_played']
  params = { 'match_id' => match_id }
  run_hooks(hooks, params)
end

def self.match_cancelled(match_id)
  hooks = Conf.settings.hooks['match_cancelled']
  params = { 'match_id' => match_id }
  run_hooks(hooks, params)
end

def self.run_hooks(hooks, params)
  hooks.each do |hook|
    if hook['type'] == 'http'
      hook_web(hook['url'], params)
    elsif hook['type'] == 'exec'
      hook_exec(hook['command'], params)
    end
  end
end

def self.hook_exec(command, params)
  command_line = command
  params.each do |k, v|
    command_line += " #{k}=#{v}"
  end
  result = `#{command_line}`
end

# TODO: improve error handling
def self.hook_web(url, params)
  uri = URI(url)
  begin
    response = Net::HTTP.post_form(uri, params)
  rescue Exception => e
    puts "HTTP POST to #{uri.to_s} failed"
    return
  end
  if response.code == '200'
    puts "HTTP POST to #{uri.to_s} executed correctly"
  else
    puts "HTTP POST to #{uri.to_s} failed with error #{response.code}"
  end
end

end
