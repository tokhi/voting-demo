require 'sinatra'
require 'redis'

set :server, 'webrick'
set :bind, '0.0.0.0'
set :port, 80

redis_host = ENV.fetch("REDIS_HOST", "redis")
redis = Redis.new(host: redis_host, port: 6379)

get '/' do
  erb :vote
end

post '/vote' do
  vote = params[:vote]
  if %w[Cats Dogs].include?(vote)
    redis.rpush('votes', vote)
    redirect '/'
  else
    status 400
    'Invalid vote'
  end
end

__END__
@@ vote
<!doctype html>
<html>
<head><title>Vote</title></head>
<body style="text-align:center; font-family: Arial; margin-top: 100px;">
  <h1 style="font-size: 4em;">Cats or Dogs?</h1>
  <form method="post" action="/vote" style="font-size: 2em;">
  <p><label><input type="radio" name="vote" value="Cats" required> Cats</label></p>
  <p><label><input type="radio" name="vote" value="Dogs"> Dogs</label></p>
  <p><button type="submit" style="font-size: 2em; padding: 20px 80px;">VOTE!</button></p>
</form>

</body>
</html>
