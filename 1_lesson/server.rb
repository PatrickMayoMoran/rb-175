require "socket"

def parse(request_line)
  http_method = get_method(request_line)
  path = get_path(request_line)
  query_parameters = get_query_parameters(request_line)

  return http_method, path, query_parameters
end

def get_method(request_line)
  request_line.split[0]
end

def get_path(request_line)
  request_line.split[1].split('?')[0]
end

def get_query_parameters(request_line)
  query_string = request_line.split[1].split('?')[1]
  return if query_string.nil?
  query_parameters = query_string.split('&')

  query_parameters_hash = {}
  query_parameters.each do |p|
    parameter, value = p.split('=')
    query_parameters_hash[parameter] = value
  end

  query_parameters_hash
end

def roll_dice(query_parameters)
  roll_results = []
  return roll_results if query_parameters.nil?

  rolls = query_parameters["rolls"].to_i
  sides = query_parameters["sides"].to_i

  rolls.times do
    roll_results << rand(1..sides)
  end

  roll_results
end

server = TCPServer.new(ENV["IP"], ENV["PORT"])
loop do
  client = server.accept

  request_line = client.gets
  puts request_line

  http_method, path, query_parameters = parse(request_line)

  client.puts "HTTP/1.1 200 OK"
  client.puts "Content-Type: text/html\r\n\r\n"
  client.puts "<html>"
  client.puts "<body>"

  client.puts request_line
  client.puts "<h1>Rolls!</h1>"
  rolls = roll_dice(query_parameters)
  rolls.each do |roll|
    client.puts "<p>", roll, "</p>"
  end

  client.puts "</body>"
  client.puts "</html>"
  client.close
end

