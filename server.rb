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
  query_string = request_line.split[1].split('?')[1]
  query_parameters = query_string.split('&')

  query_parameters_hash = {}
  query_parameters.each do |p|
    parameter, value = p.split('=')
    query_parameters_hash[parameter] = value
  end

  query_parameters_hash
end

server = TCPServer.new(ENV["IP"], ENV["PORT"])
loop do
  client = server.accept

  request_line = client.gets
  puts request_line

  request_components = parse(request_line)
  http_method = request_components[:http_method]
  path = request_components[:path]
  query_parameters = request_components[:query_parameters]

  client.puts request_line
  client.close
end

