require 'curb'
require_relative 'uvo_parser'

module Uvobot
  class UvoScraper
    BULLETIN_URL = 'https://www.uvo.gov.sk'.freeze
    SEARCH_URL = "#{BULLETIN_URL}/vestnik/oznamenia/zoznam".freeze
    NEW_ISSUE_URL = "#{BULLETIN_URL}/vestnik-a-registre/vestnik-479.html".freeze
    IT_CONTRACTS_CODE = '48000000-8 72000000-5'.freeze

    def initialize(parser = Uvobot::UvoParser, html_client = Curl)
      @parser = parser
      @html_client = html_client
    end

    def issue_ready?(release_date)
      search_query = "?date=#{release_date.strftime('%d.%m.%Y')}"

      html = @html_client.get(NEW_ISSUE_URL + search_query).body
      header = @parser.parse_issue_header(html)
      identifier = release_date.strftime('/%Y - %d.%m.%Y')
      header.include?(identifier)
    end

    def get_announcements(release_date)
      date = release_date.strftime('%d.%m.%Y')
      search_query = { kcpv: IT_CONTRACTS_CODE, dzOd: date, dzDo: date }
      html = @html_client.post(SEARCH_URL, search_query).body

      [@parser.parse_page_info(html), @parser.parse_announcements(html, BULLETIN_URL)]
    end

    def get_announcement_detail(url)
      html = @html_client.get(url).body
      @parser.parse_detail(html)
    end
  end
end
