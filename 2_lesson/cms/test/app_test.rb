ENV["RACK_ENV"] = "test"

require 'minitest/autorun'
require 'rack/test'
require 'fileutils'

require_relative "../cms.rb"

def admin_session
  {"rack.session" => { username: "admin" } }
end

def session
  last_request.env["rack.session"]
end

def create_document(name, content = "")
  File.open(File.join(data_path, name), "w") do |file|
    file.write(content)
  end
end

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    FileUtils.mkdir_p(data_path)
  end

  def teardown
    FileUtils.rm_rf(data_path)
  end

  def test_index
    files = ["history.txt", "about.md", "changes.txt"]
    files.each do |file|
      create_document(file)
    end

    get "/"

    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])

    files.each do |file|
      assert_equal(true, last_response.body.include?(file))
    end
  end

  def test_history
    create_document "history.txt"
    get "/history.txt"

    path = data_path
    file = File.read(File.join(path, "history.txt"))

    assert_equal(200, last_response.status)
    assert_equal("text/plain", last_response["Content-Type"])
    assert_equal(file, last_response.body)
  end

  def test_document_not_found
    get "not_a_document.txt"

    assert_equal(302, last_response.status)
    assert_equal "not_a_document.txt does not exist.", session[:message]
  end

  def test_viewing_markdown_document
    create_document("about.md", "# Ruby is...")
    get "/about.md"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<h1>Ruby is...</h1>"
  end

  def test_edit_document_signed_out
    create_document "changes.txt"
    get "/changes.txt/edit"

    assert_equal 302, last_response.status
    assert_equal "You must be signed in to do that.", session[:message]
  end

  def test_editing_document
    create_document "changes.txt"
    get "/changes.txt/edit", {}, admin_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, "<textarea"
    assert_includes last_response.body, %q(<button type="submit")
  end

  def test_updating_document
    post "/changes.txt", {content: "new content"}, admin_session

    assert_equal 302, last_response.status
    assert_equal "changes.txt has been updated.", session[:message]

    get "/changes.txt"
    assert_equal 200, last_response.status
    assert_includes last_response.body, "new content"
  end
  
  def test_view_new_document_form
    get "/new", {}, admin_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, "<input"
    assert_includes last_response.body, %q(<button type="submit")
  end

  def test_create_new_document
    post "/new", {new: "tiny_cat.txt"}, admin_session
    assert_equal 302, last_response.status
    assert_equal "tiny_cat.txt was created.", session[:message]

    get "/"
    assert_includes last_response.body, "tiny_cat.txt"
  end

  def test_create_document_with_no_name
    post "/new", {new: ""}, admin_session
    assert_equal 422, last_response.status
    assert_includes last_response.body, "A name is required"
  end

  def test_delete_file
    post "/new", {new: "tiny_cat.txt"}, admin_session

    post "/tiny_cat.txt/delete"
    assert_equal 302, last_response.status
    assert_equal "tiny_cat.txt has been deleted.", session[:message]

    get "/"
    refute_includes last_response.body, %q(href="tiny_cat.txt")
  end

  def test_sign_in_form
    get "/users/signin"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "<input"
    assert_includes last_response.body, %q(<button type="submit")
  end

  def test_sign_in_admin
    post "/users/signin", username: "admin", password: "secret"
    assert_equal 302, last_response.status
    assert_equal "Welcome!", session[:message]
    assert_equal "admin", session[:username]

    get last_response["Location"]
    assert_includes last_response.body, "Signed in as admin"
  end

  def test_sign_in_invalid
    post "/users/signin", username: "meow", password: "cat"

    assert_equal 422, last_response.status
    assert_includes last_response.body, "Invalid credentials"
  end

  def test_sign_out
    get "/", {}, admin_session
    assert_includes last_response.body, "Signed in as admin"

    post "/users/signout"
    assert_equal "You have been signed out.", session[:message]

    get last_response["Location"]
    assert_nil session[:username]
    assert_includes last_response.body, "Sign In"
  end
end
