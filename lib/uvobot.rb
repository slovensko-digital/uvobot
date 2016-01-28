class Uvobot
  def initialize(notifier, scraper)
    @notifier = notifier
    @scraper = scraper
  end

  def run(release_date)
    if @scraper.issue_ready?(release_date)
      notify_announcements(release_date)
    else
      @notifier.new_issue_not_published
    end
  end

  private

  def notify_announcements(release_date)
    page_info, announcements = @scraper.get_announcements(release_date)

    if announcements.count > 0
      @notifier.matching_announcements_found(page_info, announcements)
    else
      @notifier.no_announcements_found
    end
  end
end
