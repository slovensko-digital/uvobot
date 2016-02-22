require 'httparty'
require_relative 'uvo_parser'

module Uvobot
  class UvoScraper
    BULLETIN_URL = 'https://www.uvo.gov.sk'.freeze
    SEARCH_URL = "#{BULLETIN_URL}/vestnik/oznamenia/zoznam".freeze
    NEW_ISSUE_URL = "#{BULLETIN_URL}/vestnik-a-registre/vestnik-479.html".freeze
    IT_CONTRACTS_CODES = ['48000000-8', '72000000-5'].freeze

    class ScrapingError < StandardError
    end

    def initialize(parser = Uvobot::UvoParser, html_client = HTTParty)
      @parser = parser
      @html_client = html_client
    end

    def issue_ready?(release_date)
      search_query = "?date=#{release_date.strftime('%d.%m.%Y')}"

      html = @html_client.get(NEW_ISSUE_URL + search_query, verify: false).body
      result = header_includes_date?(html, release_date)

      if !result && !@parser.issue_page_valid?(html)
        raise ScrapingError, 'Stránka aktuálneho vestníka, bola pravdepodobne zmenená'
      end
      result
    end

    def header_includes_date?(html, date)
      header = @parser.parse_issue_header(html)
      identifier = date.strftime('/%Y - %d.%m.%Y')
      header.include?(identifier)
    end

    def get_announcements(release_date)
      date = release_date.strftime('%d.%m.%Y')
      code = IT_CONTRACTS_CODES.join('+')
      html = @html_client.get("#{SEARCH_URL}/?kcpv=#{code}&dzOd=#{date}&dzDo=#{date}", verify: false).body

      [@parser.parse_page_info(html), @parser.parse_announcements(html, BULLETIN_URL)]
    end

    def get_announcement_detail(url)
      html = @html_client.get(url, verify: false).body
      @parser.parse_detail(html)
    end
  end
end
