require "socket"

server = TCPServer.new(ENV["IP"], ENV["PORT"])
loop do
  client = server.accept

  request_line = client.gets
  puts request_line
  "GET /_staticlocalhost:8080/?rolls=2&sides=6& HTTP/1.1"
  request_components = parse(request_line)
  http_method = request_components[:method]
  path = request_components[:path]
  query_parameters = request_components[:query_parameters]

  http_method == "GET"
  path == "/"
  query_parameters == { "rolls"=>"2", "sides"=>"6"}

  client.puts request_line
  client.close
end

def parse(request_line)
end
