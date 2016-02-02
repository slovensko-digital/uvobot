require_relative './notifier'
require_relative '../uvo_scraper'

module Uvobot
  module Notifications
    class DiscourseNotifier < Notifier
      def initialize(discourse_client, category = 'Štátne projekty', scraper = Uvobot::UvoScraper.new)
        @client = discourse_client
        @category = category
        @scraper = scraper
      end

      def no_announcements_found
        # noop
      end

      def new_issue_not_published
        # noop
      end

      def matching_announcements_found(_page_info, announcements)
        announcements.each do |a|
          topic = announcement_to_topic(a)
          @client.create_topic(
            title: topic[:title],
            raw: topic[:body],
            category: @category
          )
        end
      end

      private

      def announcement_to_topic(announcement)
        detail = @scraper.get_announcement_detail(announcement[:link][:href])
        {
          title: announcement[:procurement_subject].to_s,
          body: ["**Obstarávateľ:** #{announcement[:procurer]}  ",
                 "**Predmet obstarávania:** #{announcement[:procurement_subject]}  ",
                 "**Cena:** #{detail[:amount]} EUR  ",
                 "**Zdroj:** [#{announcement[:link][:text]}](#{announcement[:link][:href]})"].join("\n")
        }
      end
    end
  end
end
