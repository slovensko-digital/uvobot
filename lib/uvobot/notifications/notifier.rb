require_relative 'notifier'

module Uvobot
  module Notifications
    class Notifier
      def matching_announcements_found(_page_info, _announcements)
        raise NotImplementedError, "#{self.class} must implement ##{__method__}"
      end

      def no_announcements_found
        raise NotImplementedError, "#{self.class} must implement ##{__method__}"
      end

      def new_issue_not_published
        raise NotImplementedError, "#{self.class} must implement ##{__method__}"
      end
    end
  end
end
