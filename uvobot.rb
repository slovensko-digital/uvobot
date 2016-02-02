require 'dotenv'
require 'date'
require_relative './lib/uvobot'

Dotenv.load
discourse_client = Uvobot::DiscourseClient.new(
  ENV.fetch('DISCOURSE_URL'),
  ENV.fetch('DISCOURSE_API_KEY'),
  ENV.fetch('DISCOURSE_USER')
)

notifiers = [
  Uvobot::Notifications::SlackNotifier.new(ENV.fetch('UVOBOT_SLACK_WEBHOOK')),
  Uvobot::Notifications::DiscourseNotifier.new(discourse_client)
]

Uvobot::Worker.new(
  Uvobot::UvoScraper.new(Uvobot::UvoParser),
  notifiers
).run(Date.today)
