require 'httparty'
require_relative 'uvo_parser'

module Uvobot
  class UvoScraper
    BULLETIN_URL = 'https://www.uvo.gov.sk'.freeze
    SEARCH_URL = "#{BULLETIN_URL}/vestnik/oznamenia/zoznam".freeze
    NEW_ISSUE_URL = "#{BULLETIN_URL}/vestnik-a-registre/vestnik-479.html".freeze
    IT_CONTRACTS_CODES = '48000000-8 72000000-5 48820000-2 72250000-2 72260000-5 72263000-6 72222300-0 72261000-2 48800000-6 72212000-4 72267000-4 72265000-0 48100000-9 72310000-1 72267100-0 72262000-9 72268000-1 72200000-7 72600000-6 51610000-1 50312600-1 42962000-7 48600000-4 72253200-5 72300000-8 48190000-6 72400000-4 72266000-7 48821000-9 72320000-4 72240000-9 72230000-6 72227000-2 72254000-0 48900000-7 72700000-7 51611100-9 48620000-0 72611000-6 72212422-3 48321000-4 48461000-7 51600000-8 48614000-5 48300000-1 72500000-0 72254100-1 51612000-5 48810000-9 72224000-1 48610000-7 48730000-4 48460000-0 48921000-0 79212000-3 48322000-1 72316000-3 72710000-0 48520000-9 72220000-3 48180000-3 72246000-1 48151000-1 48323000-8 48219300-9 48700000-5 72322000-8 72610000-9 42962500-2 48510000-6 72100000-6 42968000-9 48624000-8 72511000-0 48320000-7 72413000-8 72243000-0 48710000-8 48822000-6 72311100-9 72251000-9 72228000-9 72314000-9 48611000-4 72212100-0 72252000-6 48781000-6 48310000-4 48500000-3 48761000-0 48328000-3 72315000-6 72211000-7 48732000-8 79212100-4 72267200-1 48463000-1 72590000-7 72224100-2'.split(' ').freeze

    class InvalidIssuePage < StandardError
    end

    def initialize(parser = Uvobot::UvoParser, html_client = HTTParty)
      @parser = parser
      @html_client = html_client
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
