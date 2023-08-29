ENV["RACK_ENV"] = "test"

require 'minitest/autorun'
require 'rack/test'
require 'fileutils'

require_relative "../cms.rb"

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

    get last_response["Location"]

    assert_equal(200, last_response.status)
    assert_includes(last_response.body, "not_a_document.txt does not exist")

    get "/"
    refute_includes(last_response.body, "not_a_document.txt does not exist")
  end

# test/cms_test.rb
  def test_viewing_markdown_document
    get "/about.md"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<h1>Ruby is...</h1>"
  end

# test/cms_test.rb
  def test_editing_document
    create_document "changes.txt"
    get "/changes.txt/edit"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "<textarea"
    assert_includes last_response.body, %q(<button type="submit")
  end

  def test_updating_document
    post "/changes.txt", content: "new content"

    assert_equal 302, last_response.status

    get last_response["Location"]

    assert_includes last_response.body, "changes.txt has been updated"

    get "/changes.txt"
    assert_equal 200, last_response.status
    assert_includes last_response.body, "new content"
  end
end
