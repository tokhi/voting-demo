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
