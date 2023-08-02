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
  end

  def test_history
    get "/history.txt"

    assert_equal(200, last_response.status)
  end
end
