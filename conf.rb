require 'sinatra/config_file'

config_file File.join(File.dirname(File.expand_path(__FILE__)), 'config.yaml')

module Conf
  module_function
  def settings; Sinatra::Application.settings end
end
