ENV["RACK_ENV"] = "test"

require 'minitest/autorun'
require 'rack/test'

require_relative "../cms.rb"

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index
    get "/"

    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])

    files = ["history.txt", "about.md", "changes.txt"]
    files.each do |file|
      assert_equal(true, last_response.body.include?(file))
    end
  end

  def test_history
    get "/history.txt"
    root = File.expand_path("../..", __FILE__)
    file = File.read(root + "/data/history.txt")

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
end
