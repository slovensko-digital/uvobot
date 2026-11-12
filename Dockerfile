FROM ruby:4.0.9-slim

# Install compiler and pg headers for native gems.
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
  && rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="true" \
    BUNDLE_WITHOUT="development:test"

# Set working directory
RUN mkdir /app
WORKDIR /app

# Bundle and cache Ruby gems
COPY Gemfile Gemfile.lock .ruby-version ./
RUN bundle install

RUN mkdir -p tmp/pids

# Cache everything
COPY . .

# Run application by default.
# Requires SECRET_KEY_BASE (and UVOBOT_DATABASE_PASSWORD for ActiveRecord) at runtime.
CMD ["bundle", "exec", "clockwork", "config/clock.rb"]
