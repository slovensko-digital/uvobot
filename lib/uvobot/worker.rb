module Uvobot
  class Worker
    def initialize(scraper, notifiers)
      @notifiers = notifiers
      @scraper = scraper
    end

    def run(release_date)
      issue_check = @scraper.issue_ready?(release_date)
      if issue_check[:result]
        notify_announcements(release_date)
      else
        return if weekend?(release_date)
        @notifiers.each(&:new_issue_not_published)
      end
    end

    private

    def weekend?(date)
      date.saturday? || date.sunday?
    end

    def notify_announcements(release_date)
      page_info, announcements = @scraper.get_announcements(release_date)

      if announcements.count > 0
        @notifiers.each { |n| n.matching_announcements_found(page_info, announcements) }
      else
        @notifiers.each(&:no_announcements_found)
      end
    end
  end
end
