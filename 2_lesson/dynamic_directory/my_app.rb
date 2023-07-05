require 'sinatra'
require 'sinatra/reloader'
require 'erubis'

get '/' do
  "Testing Dynamic Directory"
  @files = Dir.glob('*')

  erb :home
end
