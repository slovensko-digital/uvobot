require_relative 'notifier'

module Uvobot
  module Notifications
    class DiscourseNotifier < Notifier
      def initialize(discourse_client, category, scraper)
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
        body_messages = ["**Obstarávateľ:** #{announcement[:procurer]}",
                         "**Predmet obstarávania:** #{announcement[:procurement_subject]}",
                         detail_messages(detail),
                         "**Zdroj:** [#{announcement[:link][:text]}](#{announcement[:link][:href]})"]

        {
          title: announcement[:procurement_subject].to_s,
          body: body_messages.flatten(1).join("  \n")
        }
      end

      def detail_messages(detail)
        if detail
          ["**Cena:** #{fallback_if_nil(detail[:amount])}",
           "**Druh postupu:** #{fallback_if_nil(detail[:procurement_type])}"]
        else
          ['**Detaily sa nepodarilo extrahovať.**']
        end
      end

      def fallback_if_nil(value)
        value.nil? ? 'Nepodarilo sa extrahovať' : value
      end
    end
  end
end
