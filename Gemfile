source "https://rubygems.org"

ruby "4.0.9"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.4", ">= 8.1.4.1"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "bootsnap", require: false

gem "dotenv-rails"
gem "clockwork", "~> 3.0"

gem "httparty"
gem "discourse_api"
gem "nokogiri"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "rspec-rails"
end

group :development do
  gem "listen"
end

group :test do
  # Use system testing with Capybara
  gem "capybara"
end
