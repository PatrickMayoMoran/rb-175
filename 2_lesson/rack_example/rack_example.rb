require 'rack'
require 'rackup'

class MyApp
  def call(env)
    ['200', { "Content-Type" => "text/plain" }, [env.to_s]]
  end
end

Rackup::Handler::WEBrick.run MyApp.new
