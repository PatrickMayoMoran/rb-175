require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

before do
  @table_of_contents = File.readlines('data/toc.txt')
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/search" do
  erb :search
end

get "/chapters/:number" do
  chapter_number = params[:number].to_i

  redirect "/" unless (1..@table_of_contents.size).cover? chapter_number

  chapter_name = @table_of_contents[chapter_number - 1]
  @title = "Chapter #{chapter_number}: #{chapter_name}"

  @chapter = File.read("data/chp#{params[:number]}.txt")

  erb :chapter
end

not_found do
  redirect "/"
end

helpers do
  def in_paragraphs(text)
    paragraphs = text.split("\n\n")
    paragraphs.map do |paragraph|
      "<p>#{paragraph}</p>"
    end.join
  end
end
