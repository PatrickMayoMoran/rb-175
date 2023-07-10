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
  @results = chapters_matching(params[:query])

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

def each_chapter
  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, name, contents
  end
end

def chapters_matching(query)
  results = []

  return results if !query || query.empty?

  each_chapter do |number, name, contents|
    results << {number: number, name: name} if contents.include?(query)
  end

  results
end
