class Uvobot
  def initialize(notifier, scraper, publisher)
    @notifier = notifier
    @scraper = scraper
    @publisher = publisher
  end

  def run(release_date)
    if @scraper.issue_ready?(release_date)
      process_announcements(release_date)
    else
      @notifier.new_issue_not_published
    end
  end

  private

  def process_announcements(release_date)
    page_info, announcements = @scraper.get_announcements(release_date)

    if announcements.count > 0
      @notifier.matching_announcements_found(page_info, announcements)
      details = @scraper.get_announcements_details(announcements)
      @publisher.publish_announcements(details)
    else
      @notifier.no_announcements_found
    end
  end
end
