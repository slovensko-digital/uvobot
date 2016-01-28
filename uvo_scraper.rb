require "curb"

class UvoScraper
  SEARCH_URL = "https://www2.uvo.gov.sk/evestnik?p_p_id=evestnik_WAR_eVestnikPortlets&p_p_lifecycle=1&p_p_state=normal&p_p_mode=view&p_p_col_id=column-2&p_p_col_pos=1&p_p_col_count=2".freeze
  NEW_ISSUE_URL = "https://www2.uvo.gov.sk/evestnik/-/vestnik/aktual".freeze
  IT_CONTRACTS_CODE = 72

  def initialize(parser_class, release_date, html_client=Curl)
    @parser = parser_class
    @html_client = html_client
    @release_date = release_date
  end

  def issue_ready?
    html = @html_client.get(NEW_ISSUE_URL).body
    header = @parser.new(html).parse_issue_header
    identifier = @release_date.strftime("/%Y - %-d.%-m.%Y")
    header.include?(identifier)
  end

  def get_announcements
    date = @release_date.strftime("%d.%m.%Y")
    search_query = { cpv: IT_CONTRACTS_CODE, datumZverejneniaOd: date, datumZverejneniaDo: date }
    html = @html_client.post(SEARCH_URL, search_query).body

    p = @parser.new(html)
    [p.parse_page_info, p.parse_announcements]
  end
end