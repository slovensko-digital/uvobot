require 'dotenv'
require 'date'
require './lib/uvobot'
require './lib/slack_notifier'
require './lib/uvo_scraper'
require './lib/uvo_parser'

Dotenv.load

Uvobot.new(
  SlackNotifier.new(ENV.fetch('UVOBOT_SLACK_WEBHOOK')),
  UvoScraper.new(UvoParser)
).run(Date.today)
