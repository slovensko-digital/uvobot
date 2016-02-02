require_relative './base'

module Uvobot
  module Notifications
    class DiscourseNotifier < Base
      def initialize(discourse_client, category = 'Štátne projekty')
        @client = discourse_client
        @category = category
      end

      def no_announcements_found
        # Does nothing for now.
      end

      def new_issue_not_published
        # Does nothing for now.
      end

      def matching_announcements_found(_page_info, announcements)
        announcements.each do |a|
          topic = announcement_to_topic(a)
          @client.create_topic(title: topic[:title],
                               raw: topic[:body],
                               category: @category)
        end
      end

      private

      def announcement_to_topic(announcement)
        {
          title: announcement[:procurement_subject].to_s,
          body: "**Obstarávateľ:** #{announcement[:procurer]}  \n" \
               "**Predmet obstarávania:** #{announcement[:procurement_subject]}  \n" \
               "**Cena:** #{announcement[:detail].call[:amount]} EUR  \n" \
               "**Zdroj:** [#{announcement[:link][:text]}](#{announcement[:link][:href]})"
        }
      end
    end
  end
end
