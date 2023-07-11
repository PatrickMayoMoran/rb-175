require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'

before do
  @users = YAML.load_file("users.yml")
end

get '/' do
end

helpers do
  
end
