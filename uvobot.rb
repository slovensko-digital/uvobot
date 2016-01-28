class Uvobot
  def initialize(notifier, scraper)
    @notifier = notifier
    @scraper = scraper
  end

  def run
    if @scraper.issue_ready?
      notify_announcements
    else
      @notifier.new_issue_not_published
    end
  end

  private

  def notify_announcements
    page_info, announcements = @scraper.get_announcements

    if announcements.count > 0
      @notifier.matching_announcements_found(page_info, announcements)
    else
      @notifier.no_announcements_found
    end
  end
end
