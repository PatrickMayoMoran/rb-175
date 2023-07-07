require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  @table_of_contents = File.readlines('data/toc.txt')
  erb :home
end

get "/chapters/:number" do
  @title = "Chapter #{params[:number]}"
  @table_of_contents = File.readlines('data/toc.txt')
  @chapter = File.read("data/chp#{params[:number]}.txt")

  erb :chapter
end
