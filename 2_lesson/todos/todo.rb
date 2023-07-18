require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

get "/" do
  @lists = [
    {name: "Lunch"},
    {name: "Dinner Groceries"}
  ]
  erb :lists, layout: :layout
end
# set :session_secret, SecureRandom.hex(32)
