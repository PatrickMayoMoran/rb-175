require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

get "/lists" do
  @lists = [
    {name: "Lunch", todos: []},
    {name: "Dinner Groceries", todos: []}
  ]
  erb :lists, layout: :layout
end
# set :session_secret, SecureRandom.hex(32)
