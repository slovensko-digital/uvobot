require 'dotenv'
require 'date'
require_relative './lib/uvobot'
require_relative 'lib/notifiers'
require_relative './lib/uvo_scraper'
require_relative './lib/uvo_parser'
require_relative './lib/discourse_client'

Dotenv.load
discourse_client = DiscourseClient.new(
  ENV.fetch('DISCOURSE_URL'),
  ENV.fetch('DISCOURSE_API_KEY'),
  ENV.fetch('DISCOURSE_USER')
)

notifiers = [
  Notifiers::Slack.new(ENV.fetch('UVOBOT_SLACK_WEBHOOK')),
  Notifiers::Discourse.new(discourse_client)
]

Uvobot.new(
  notifiers,
  UvoScraper.new(UvoParser)
).run(Date.today)
