require 'net/http'

module HookManager

def self.match_played(match_id)
  hooks = Conf.settings.hooks.match_played
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
    if hook['type'] == 'web'
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

def self.hook_web(url, params)
  # TODO: add parameters to the post and process errors better
  response = Net::HTTP.get_response(URI(url))
  if response.code != '200'
    raise "HTTP GET to #{uri.to_s} failed with error #{response.code}"
  end
end

end
