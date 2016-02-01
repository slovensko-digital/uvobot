require_relative './base'

module Notifiers
  class Discourse < Base
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

    def matching_announcements_found(page_info, announcements)
      announcements.each do |a|
        begin
          topic = announcement_to_topic(a)
          @client.create_topic(title: topic[:title],
                               raw: topic[:body],
                               category: @category)
        rescue @client.class::Error => e
          # discourse api/faraday bug - most probably
          next if e.message == "757: unexpected token at 'null'"
          puts "API Error: #{e.message}"
        end
      end
    end

    private

    def announcement_to_topic(announcement)
      {
        title: announcement[:procurement_subject].to_s,
        body: "**Obstarávateľ:** #{announcement[:procurer]}  \n" \
             "**Predmet obstarávania:** #{announcement[:procurement_subject]}  \n" \
             "**Cena:** #{announcement[:amount]} EUR  \n" \
             "**Zdroj:** [#{announcement[:link][:text]}](#{announcement[:link][:href]})"
      }
    end
  end
end
