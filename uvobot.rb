require 'dotenv'
require 'date'
require './lib/uvobot'
require './lib/slack_notifier'
require './lib/uvo_scraper'
require './lib/uvo_parser'
require './lib/discourse_publisher'
require './lib/discourse_client'

Dotenv.load
discourse_client = DiscourseClient.new(ENV.fetch('DISCOURSE_URL'),
                                            ENV.fetch('DISCOURSE_API_KEY'),
                                            ENV.fetch('DISCOURSE_USER') )

Uvobot.new(
  SlackNotifier.new(ENV.fetch('UVOBOT_SLACK_WEBHOOK')),
  UvoScraper.new(UvoParser),
  DiscoursePublisher.new(discourse_client)
).run(Date.today)
