require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

get "/" do
  #File.read "public/template.html"
  erb :home
end
