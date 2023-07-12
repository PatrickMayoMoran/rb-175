require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'

before do
  @users = YAML.load_file("users.yml")
end

get '/' do
  erb :index
end

get '/:user' do
  @user = params[:user]

  erb :user
end

helpers do
  def display_users(users)
    users.keys.map do |user|
      "<li><a href=\"/#{user}\">#{user}</a></li>"
    end.join
  end

  def display_user(user, users)
    info = users[user]
    info.each do |key, value|
    end
  end
end
