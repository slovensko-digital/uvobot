require_relative 'notifier'

module Uvobot
  module Notifications
    class DiscourseNotifier < Notifier
      DETAIL_MESSAGES = {
        announcement_type: '**Typ oznamu:** %s',
        amount: '**Cena:** %s',
        procurement_type: '**Druh postupu:** %s',
        project_runtime: '**Trvanie projektu:** %s',
        project_contract_runtime: '**Trvanie zmluvy, alebo lehota dodania :** %s',
        proposal_placing_term: '**Lehota na predkladanie ponúk:** %s',
        procurement_winner: "**Víťaz obstarávania:**  \n %s"
      }.freeze

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
            category: @category,
            procurement_id: topic[:procurement_id]
          )
        end
      end

      private

      def announcement_to_topic(announcement)
        detail = @scraper.get_announcement_detail(announcement[:link][:href])
        body_messages = [
          "**Obstarávateľ:** #{announcement[:procurer]}",
          "**Predmet obstarávaniaA:** #{announcement[:procurement_subject]}",
          build_detail_messages(detail),
          "**Zdroj:** [#{announcement[:link][:text]}](#{announcement[:link][:href]})"
        ].flatten(1)

        {
          title: announcement.fetch(:procurement_subject),
          body: body_messages.join("  \n"),
          procurement_id: detail.fetch(:procurement_id)
        }
      end

      def build_detail_messages(details)
        DETAIL_MESSAGES.each_with_object([]) do |(type, template), messages|
          value = details[type]
          messages << (template % value) if value
        end
      end
    end
  end
end
