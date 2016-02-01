module Notifiers
  class Base
    def matching_announcements_found(page_info, announcements)
      fail 'Interface method not implemented!'
    end

    def no_announcements_found
      fail 'Interface method not implemented!'
    end

    def new_issue_not_published
      fail 'Interface method not implemented!'
    end
  end
end
