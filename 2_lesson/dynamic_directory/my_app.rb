require 'sinatra'
require 'sinatra/reloader'
require 'erubis'

get '/' do
  @files = Dir.glob('public/*')

  erb :home
end
