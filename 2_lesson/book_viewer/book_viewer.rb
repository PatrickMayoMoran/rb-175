require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

get "/" do
  #File.read "public/template.html"
  @title = "The Adventures of Sherlock Holmes"
  erb :home
end
