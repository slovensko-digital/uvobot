require "dotenv"
require "./uvobot"

Dotenv.load!
Uvobot.new(SlackNotifier.new(ENV.fetch("UVOBOT_SLACK_WEBHOOK")), UvoScraper.new).run