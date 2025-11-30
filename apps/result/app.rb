require 'sinatra'
require 'pg'

set :server, 'webrick'
set :bind, '0.0.0.0'
set :port, 80

db = nil
print "Result waiting for database"
loop do
  begin
    require 'pg'

  db = PG.connect(
    host:     ENV.fetch("POSTGRES_HOST", "db"),
    dbname:   ENV.fetch("POSTGRES_DB", "votes"),
    user:     ENV.fetch("POSTGRES_USER", "postgres"),
    password: ENV.fetch("POSTGRES_PASSWORD", "postgres"),
    port:     ENV.fetch("POSTGRES_PORT", 5432),
    connect_timeout: 2
  )

    puts " connected!"
    break
  rescue
    print "."
    sleep 2
  end
end

get '/' do
  rows = db.exec('SELECT option, count FROM vote_counts ORDER BY count DESC')
  erb :results, locals: { rows: rows }
end

__END__
@@ results
<!doctype html>
<html>
<head><title>Results</title></head>
<body style="text-align:center; font-family: Arial; margin-top: 80px;">
  <h1 style="font-size: 4em;">Live Results</h1>
  <ul style="list-style: none; font-size: 3em;">
    <% rows.each do |r| %>
      <li><b><%= r['option'] %></b> — <%= r['count'] || 0 %> votes</li>
    <% end %>
  </ul>
  <br><br><a href="http://localhost:8080" style="font-size: 1.5em;">← Vote Again</a>
</body>
</html>
