require 'curb'

class UvoScraper
  SEARCH_URL = 'https://www2.uvo.gov.sk/evestnik?p_p_id=evestnik_WAR_eVestnikPortlets&p_p_lifecycle=1' \
               '&p_p_state=normal&p_p_mode=view&p_p_col_id=column-2&p_p_col_pos=1&p_p_col_count=2'.freeze
  NEW_ISSUE_URL = 'https://www2.uvo.gov.sk/evestnik/-/vestnik/aktual'.freeze
  IT_CONTRACTS_CODE = 72

  def initialize(parser, html_client = Curl)
    @parser = parser
    @html_client = html_client
  end

  def issue_ready?(release_date)
    html = @html_client.get(NEW_ISSUE_URL).body
    header = @parser.parse_issue_header(html)
    identifier = release_date.strftime('/%Y - %-d.%-m.%Y')
    header.include?(identifier)
  end

  def get_announcements(release_date)
    date = release_date.strftime('%d.%m.%Y')
    search_query = { cpv: IT_CONTRACTS_CODE, datumZverejneniaOd: date, datumZverejneniaDo: date }
    html = @html_client.post(SEARCH_URL, search_query).body

    [@parser.parse_page_info(html), @parser.parse_announcements(html)]
  end
end
