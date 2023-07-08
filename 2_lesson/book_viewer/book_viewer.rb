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

get "/chapters/:number" do
  chapter_number = params[:number].to_i
  chapter_name = @table_of_contents[chapter_number - 1]
  @title = "Chapter #{chapter_number}: #{chapter_name}"

  @chapter = File.read("data/chp#{params[:number]}.txt")

  erb :chapter
end

helpers do
  def in_paragraphs(text)
    paragraphs = text.split("\n\n")
    paragraphs.map do |paragraph|
      "<p>#{paragraph}</p>"
    end.join
  end
end
