require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  @table_of_contents = File.readlines('data/toc.txt')
  erb :home
end

get "/chapters/1" do
  @title = "Chapter 1"
  @table_of_contents = File.readlines('data/toc.txt')
  @chapter_1 = File.read('data/chp1.txt')
end
