require 'dotenv'
require 'date'
require_relative 'lib/uvobot'

Dotenv.load

notifiers = []

if ENV['UVOBOT_SLACK_WEBHOOK']
  notifiers << Uvobot::Notifications::SlackNotifier.new(ENV.fetch('UVOBOT_SLACK_WEBHOOK'))
end

if ENV['DISCOURSE_URL']
  discourse_client = Uvobot::DiscourseClient.new(
    ENV.fetch('DISCOURSE_URL'),
    ENV.fetch('DISCOURSE_API_KEY'),
    ENV.fetch('DISCOURSE_USER')
  )
  notifiers << Uvobot::Notifications::DiscourseNotifier.new(
    discourse_client,
    ENV.fetch('DISCOURSE_TARGET_CATEGORY'),
    Uvobot::UvoScraper.new
  )
end

notifiers << Uvobot::Notifications::ConsoleNotifier.new

Uvobot::Worker.new(
  Uvobot::UvoScraper.new,
  notifiers
).run(Date.today)
