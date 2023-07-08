require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  @table_of_contents = File.readlines('data/toc.txt')
  erb :home
end

get "/chapters/:number" do
  @table_of_contents = File.readlines('data/toc.txt')

  chapter_number = params[:number].to_i
  chapter_name = @table_of_contents[chapter_number - 1]
  @title = "Chapter #{chapter_number}: #{chapter_name}"

  @chapter = File.read("data/chp#{params[:number]}.txt")

  erb :chapter
end
