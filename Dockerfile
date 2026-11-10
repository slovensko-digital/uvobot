FROM ruby:4.0.9-slim

# Install system dependencies: compiler and pg headers for native gems,
# Chrome for selenium-driven scraping.
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl \
    gnupg \
  && curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qq && apt-get install -y --no-install-recommends google-chrome-stable \
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
