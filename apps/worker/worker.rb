require 'redis'
require 'pg'

print "Worker waiting for database"
db = nil
loop do
  begin
    db = PG.connect(
    host:     ENV.fetch("POSTGRES_HOST", "db"),       # fallback for Docker Compose
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

db.exec <<-SQL
  CREATE TABLE IF NOT EXISTS vote_counts (
    option VARCHAR(10) PRIMARY KEY,
    count INTEGER DEFAULT 0
  )
SQL

redis_host = ENV.fetch("REDIS_HOST", "redis") # default to docker-compose
redis = Redis.new(host: redis_host, port: 6379)

puts "Worker ready"

loop do
  _, vote = redis.brpop('votes', timeout: 10)
  next unless vote && %w[Cats Dogs].include?(vote.strip)

  begin
    db.exec_params(
      "INSERT INTO vote_counts (option, count) VALUES ($1, 1) ON CONFLICT (option) DO UPDATE SET count = vote_counts.count + 1",
      [vote.strip]
    )
    puts "Processed vote: #{vote.strip}"
  rescue => e
    puts "Error processing vote '#{vote.strip}': #{e.message}"
  end
end
