require 'sinatra'
require 'sinatra/reloader'
require 'erubis'

get '/' do
  @files = Dir.glob('public/*').map {|file| File.basename(file) }.sort

  erb :home
end
