FROM ruby:3.2-slim
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends libpq-dev && rm -rf /var/lib/apt/lists/*
COPY Gemfile ./
RUN bundle install --jobs 4 --retry 3
COPY . .
CMD ["ruby", "worker.rb"]
