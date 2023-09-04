require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require "tilt/erubis"
require "redcarpet"
require "yaml"
require "bcrypt"

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
  # set :erb, :escape_html => true
end

def load_user_credentials
  credentials_path = if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/users.yml", __FILE__)
  else
    File.expand_path("../users.yml", __FILE__)
  end

  YAML.load_file(credentials_path)
end

def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end

def render_markdown(text)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(text)
end

def load_file_content(path)
  content = File.read(path)
  case File.extname(path)
    when ".txt"
      headers["Content-type"] = "text/plain"
      content
    when ".md"
      erb render_markdown(content)
  end
end

def user_signed_in?
  session.key?(:username)
end

def valid_credentials?(username, password)
  credentials = load_user_credentials

  if credentials.key?(username) 
    bcrypt_password = BCrypt::Password.new(credentials[username])
    bcrypt_password == password
  else
    false
  end
end

def require_sign_in
  unless user_signed_in?
    session[:message] = "You must be signed in to do that."
    redirect "/" 
  end
end

get "/" do
  pattern = File.join(data_path, "*")
  @files = Dir.glob(pattern).map do |path|
    File.basename(path)
  end
  erb :index
end

get "/users/signin" do
  erb :signin
end

post "/users/signout" do
  session.delete(:username)
  session[:message] = "You have been signed out."
  redirect "/"
end

post "/users/signin" do
  username = params[:username]

  if valid_credentials?(username, params[:password])
    session[:username] = username
    session[:message] = "Welcome!"
    redirect "/"
  else
    session[:message] = "Invalid credentials"
    status 422
    erb :signin
  end
end

get "/new" do
  require_sign_in

  erb :new
end

get "/:filename" do
  filename = params[:filename]
  file_path = File.join(data_path, filename)
  file_exists = File.file?(file_path)

  if file_exists
    load_file_content(file_path)
  else
    session[:message] = "#{filename} does not exist."
    redirect "/"
  end
end

get "/:filename/edit" do
  require_sign_in

  file_path = File.join(data_path, params[:filename])

  @filename = params[:filename]
  @content = File.read(file_path)

  erb :edit
end

post "/:filename/delete" do
  require_sign_in

  filename = params[:filename]
  file_path = File.join(data_path, params[:filename])
  
  FileUtils.rm(file_path)
  session[:message] = "#{filename} has been deleted."
  redirect "/"
end

post "/new" do
  require_sign_in

  document = params[:new].strip

  if document.empty?
    session[:message] = "A name is required"
    status 422
    erb :new
  else
    file_path = File.join(data_path, document)

    FileUtils.touch(file_path)
    session[:message] = "#{document} was created."
    redirect "/"
  end
end

post "/:filename" do
  require_sign_in

  file_path = File.join(data_path, params[:filename])

  File.write(file_path, params[:content])

  session[:message] = "#{params[:filename]} has been updated."
  redirect "/"
end

