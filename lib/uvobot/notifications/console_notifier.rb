require 'json'
require 'httparty'
require_relative 'notifier'

module Uvobot
  module Notifications
    class ConsoleNotifier < Notifier
      def new_issue_not_published
        send_message('*Fíha, dnes na ÚVO nevyšlo nové vydanie vestníka?*')
      end

      def matching_announcements_found(page, announcements)
        send_message("Našiel som niečo nové na ÚVO! (#{page})")

        announcements.each do |a|
          send_message("<#{a[:link][:href]} |#{a[:link][:text]}>: *#{a[:procurer]}* #{a[:procurement_subject]}")
        end
      end

      def no_announcements_found
        send_message('Dnes som nenašiel žiadne nové IT zákazky.')
      end

      private

      def send_message(text)
        puts text
      end
    end
  end
end
