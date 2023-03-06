FROM ruby:2.7.2

# Install packages
RUN apt-get update && apt-get install -y build-essential nodejs libpq-dev
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt-get install -y ./google-chrome-stable_current_amd64.deb

# Set working directory
RUN mkdir /app
WORKDIR /app

# Bundle and cache Ruby gems
COPY Gemfile* ./
RUN bundle config set deployment true
RUN bundle config set without development:test
RUN bundle install

RUN mkdir -p tmp/pids

# Cache everything
COPY . .

# Run application by default
CMD ["bundle", "exec", "clockwork", "config/clock.rb"]
