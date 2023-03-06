require 'httparty'
require_relative 'uvo_parser'
require 'webdrivers/chromedriver'
require 'selenium-webdriver'

module Uvobot
  class UvoScraper
    BULLETIN_URL = 'https://www.uvo.gov.sk'.freeze
    SEARCH_URL = "#{BULLETIN_URL}/vestnik-a-registre/vestnik/oznamenia".freeze
    NEW_ISSUE_URL = "#{BULLETIN_URL}/vestnik-a-registre/vestnik".freeze
    IT_CONTRACTS_CODES = '48000000-8 72000000-5 48820000-2 72250000-2 72260000-5 72263000-6 72222300-0 72261000-2 48800000-6 72212000-4 72267000-4 72265000-0 48100000-9 72310000-1 72267100-0 72262000-9 72268000-1 72200000-7 72600000-6 51610000-1 50312600-1 42962000-7 48600000-4 72253200-5 72300000-8 48190000-6 72400000-4 72266000-7 48821000-9 72320000-4 72240000-9 72230000-6 72227000-2 72254000-0 48900000-7 72700000-7'.split(' ').freeze

    class InvalidIssuePage < StandardError
    end

    def initialize(parser = Uvobot::UvoParser, html_client = HTTParty)
      @parser = parser
      @html_client = html_client

      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--headless')
      options.add_argument('--no-sandbox')
      @driver = Selenium::WebDriver::Driver.for(:chrome, options: options)
      @driver.manage.timeouts.implicit_wait = 30
    end

    def issue_ready?(release_date)
      search_query = "?date=#{release_date.strftime('%d.%m.%Y')}"

      html = @html_client.get(NEW_ISSUE_URL + search_query, verify: false).body
      result = header_includes_date?(html, release_date)

      raise InvalidIssuePage if !result && !@parser.issue_page_valid?(html)
      result
    end

    def header_includes_date?(html, date)
      header = @parser.parse_issue_header(html)
      identifier = date.strftime('/%Y - %d.%m.%Y')
      header.include?(identifier)
    end

    def get_announcements(release_date)
      from = release_date.strftime('%d.%m.%Y')
      to = release_date.next_day.strftime('%d.%m.%Y')
      code = IT_CONTRACTS_CODES.join('+')

      @driver.get("#{SEARCH_URL}?a=listNotice&kcpv=#{code}&dzOd=#{from}&dzDo=#{to}")
      @driver.find_element(:id, 'lists-table')
      html = @driver.page_source

      [@parser.parse_page_info(html), @parser.parse_announcements(html, BULLETIN_URL)]
    end

    def get_announcement_detail(url)
      html = @html_client.get(url, verify: false).body
      @parser.parse_detail(html)
    end
  end
end
