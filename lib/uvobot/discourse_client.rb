require 'discourse_api'

module Uvobot
  class DiscourseClient
    def initialize(host, api_key, api_username)
      @client = DiscourseApi::Client.new(host, api_key, api_username)
    end

    def create_topic(args = {})
      @client.create_topic(args)
    rescue DiscourseApi::Error
      return nil
    end
  end
end
