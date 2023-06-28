require "socket"

def parse(request_line)
  request_components = {}

  request_components[:http_method] = get_method(request_line)
  request_components[:path] = get_path(request_line)
  request_components[:query_parameters] = get_query_parameters(request_line)

  request_components
end

def get_method(request_line)
  request_line.split[0]
end

def get_path(request_line)
  request_line.split[1].split('?')[0]
end

def get_query_parameters(request_line)
end

server = TCPServer.new(ENV["IP"], ENV["PORT"])
loop do
  client = server.accept

  request_line = client.gets
  puts request_line
  "GET /_staticlocalhost:8080/?rolls=2&sides=6& HTTP/1.1"
  request_components = parse(request_line)
  http_method = request_components[:http_method]
  path = request_components[:path]
  query_parameters = request_components[:query_parameters]

  puts http_method == "GET"
  puts path == "/"
  puts query_parameters == { "rolls"=>"2", "sides"=>"6"}

  client.puts request_line
  client.close
end

