require "./slack_notifier"
require "./uvo_scraper"

class Uvobot
  def initialize(notifier, scraper)
    @notifier = notifier
    @scraper = scraper
  end

  def run
    if @scraper.issue_ready?
      page_info, announcements = @scraper.announcements
      @notifier.matching_announcements(page_info, announcements)
    else
      @notifier.new_issue_not_published
    end
  end
end
