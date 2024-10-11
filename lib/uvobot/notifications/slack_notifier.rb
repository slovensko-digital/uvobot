require 'json'
require 'httparty'
require_relative 'notifier'

module Uvobot
  module Notifications
    class SlackNotifier < Notifier
      def initialize(slack_webhook, channel, http_client = HTTParty)
        @slack_webhook = slack_webhook
        @channel = channel ? channel : 'general'
        @http_client = http_client
      end

      def new_issue_not_published
        send_message('*Fíha, dnes na ÚVO nevyšlo nové vydanie vestníka?*')
      end

      def matching_announcements_found(page, announcements)
        send_message("Našiel som niečo nové na ÚVO! (#{page})")

        announcements.each do |a|
          send_message("<#{a[:link][:href]}|#{a[:link][:text]}>: *#{a[:procurer]}* #{a[:procurement_subject]}")
        end
      end

      def no_announcements_found
        send_message('Dnes som nenašiel žiadne nové IT zákazky.')
      end

      private

      def send_message(text)
        @http_client.post(@slack_webhook, body: payload(text))
      end

      def payload(text)
        {
          text: text,
          channel: "##{@channel}",
          username: 'uvobot',
          icon_emoji: ':mag_right:'
        }.to_json
      end
    end
  end
end
