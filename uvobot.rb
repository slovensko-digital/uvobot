require 'dotenv'
require './slack_notifier'
require './uvo_scraper'

Dotenv.load!

class Uvobot
  def initialize(notifier, scraper)
    @notifier = notifier
    @scraper = scraper
  end

  def run
     if @scraper.issue_ready?
       page_info, announcements = @scraper.announcements
       @notifier.announcements_found(page_info, announcements)
     else
       @notifier.new_issue_not_published
     end
  end
end

Uvobot.new(SlackNotifier.new(ENV.fetch('UVOBOT_SLACK_WEBHOOK')),
           UvoScraper.new).run