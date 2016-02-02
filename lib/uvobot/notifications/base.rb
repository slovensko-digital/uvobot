require 'abstract_type'

module Uvobot
  module Notifications
    class Base
      include AbstractType

      abstract_method :matching_announcements_found
      abstract_method :no_announcements_found
      abstract_method :new_issue_not_published
    end
  end
end
