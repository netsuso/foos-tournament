require 'dotenv'
env = ENV["RACK_ENV"] || "development"
Dotenv.load(".env", ".env.#{env}")
