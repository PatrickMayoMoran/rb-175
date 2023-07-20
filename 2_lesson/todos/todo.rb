require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
end

before do
  session[:lists] ||= []
end

get "/" do
  redirect "/lists"
end

# View all lists
get "/lists" do
  @lists = session[:lists]
  erb :lists, layout: :layout
end

# Render new list form
get "/lists/new" do
  erb :new_list, layout: :layout
end

# Create a new list
post "/lists" do
  list_name = params[:list_name].strip
  error = error_for_list_name(list_name)

  if error
    session[:error] = error
    erb :new_list, layout: :layout
  else
    session[:lists] << {name: list_name, todos: []}
    session[:success] = "The list has been created."
    redirect "/lists"
  end
end

def error_for_list_name(name)
  if session[:lists].any? {|list| list[:name] == name}
    "That list name is already taken - please choose a different name"
  elsif !(1..100).cover? name.size
    "The list name must be between 1 and 100 characters."
  end
end

get "/lists/:id" do
  @list_id = params[:id].to_i
  @list = session[:lists][@list_id]
  erb :list, layout: :layout
end

get "/lists/:id/edit" do
  id = params[:id].to_i
  @list = session[:lists][id]
  erb :edit_list, layout: :layout
end

post "/lists/:id" do
  list_name = params[:list_name].strip
  @list_id = params[:id].to_i
  @list = session[:lists][@list_id]

  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :edit_list, layout: :layout
  else
    @list[:name] = list_name
    session[:success] = "The list name has been changed."
    redirect "/lists/#{@list_id}"
  end
end

post "/lists/:id/delete" do
  id = params[:id].to_i
  session[:lists].delete_at(id)
  session[:success] = "The list has been deleted."
  redirect "/lists"
end

post "/lists/:list_id/:todo_id/delete" do
  @list_id = params[:list_id].to_i
  @todo_id = params[:todo_id].to_i
  list = session[:lists][@list_id]
  list[:todos].delete_at(@todo_id)
  
  session[:success] = "The todo has been deleted."
  redirect "/lists/#{@list_id}"
end

post "/lists/:list_id/todos" do
  todo_name = params[:todo].strip
  @list_id = params[:list_id].to_i
  @list = session[:lists][@list_id]

  error = error_for_todo(todo_name, @list)
  if error
    session[:error] = error
    erb :list, layout: :layout
  else
    @list[:todos] << {name: todo_name, completed: false}
    session[:success] = "#{todo_name} added to the list."

    redirect "/lists/:list_id"
  end
end

def error_for_todo(name, list)
  if !(1..100).cover? name.size
    "The todo name must be between 1 and 100 characters."
  end
end
