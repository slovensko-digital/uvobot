require 'discourse_api'

module Uvobot
  class DiscourseClient < DiscourseApi::Client
    def create_topic(args = {})
      super(args)
    rescue DiscourseApi::Error => e
      # puts e.message
      return nil
    end
  end
end
