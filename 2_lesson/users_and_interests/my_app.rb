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
  @user = params[:user].to_sym

  erb :user
end

helpers do
  def display_users(users)
    users.keys.map do |user|
      display_user(user)
    end.join
  end

  def display_user(user)
    "<li><a href=\"/#{user}\">#{user}</a></li>"
  end

  def count_interests(users)
    users.reduce(0) do |sum, (user,hash)|
      sum + hash[:interests].count
    end
  end

end
