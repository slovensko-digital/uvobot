require "dotenv"
require "date"
require "./uvobot"
require "./slack_notifier"
require "./uvo_scraper"
require "./uvo_parser"

Dotenv.load!

Uvobot.new(SlackNotifier.new(ENV.fetch("UVOBOT_SLACK_WEBHOOK")),
           UvoScraper.new(UvoParser, Date.today)).run
