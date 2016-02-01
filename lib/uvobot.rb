class Uvobot
  def initialize(notifiers, scraper)
    @notifiers = notifiers
    @scraper = scraper
  end

  def run(release_date)
    if @scraper.issue_ready?(release_date)
      notify_announcements(release_date)
    else
      @notifiers.each { |n| n.send(:new_issue_not_published) }
    end
  end

  private

  def notify_announcements(release_date)
    page_info, announcements = @scraper.get_full_announcements(release_date)

    if announcements.count > 0
      @notifiers.each { |n| n.send(:matching_announcements_found, page_info, announcements) }
    else
      @notifiers.each { |n| n.send(:no_announcements_found) }
    end
  end
end
