require "curb"
require "nokogiri"

class UvoScraper

  SEARCH_URL = "https://www2.uvo.gov.sk/evestnik?p_p_id=evestnik_WAR_eVestnikPortlets&p_p_lifecycle=1&p_p_state=normal&p_p_mode=view&p_p_col_id=column-2&p_p_col_pos=1&p_p_col_count=2".freeze
  NEW_ISSUE_URL = "https://www2.uvo.gov.sk/evestnik/-/vestnik/aktual".freeze

  def issue_ready?
    html = Curl.get(NEW_ISSUE_URL).body
    header = Nokogiri::HTML.parse(html).css("h1")[1]
    identifier = Time.now.strftime("/%Y - %-d.%-m.%Y")
    header.text.include?(identifier)
  end

  def announcements
    today = Time.now.strftime("%d.%m.%Y")
    # cpv=72 filters out only IT related announcements
    search_query = { cpv: 72, datumZverejneniaOd: today, datumZverejneniaDo: today }
    html = Curl.post(SEARCH_URL, search_query).body
    parse_page(html)
  end

  private

  def parse_page(html)
    announcements = []
    doc = Nokogiri::HTML.parse(html)

    page_info = doc.css(".search-results").first.text.strip
    doc.css(".oznamenie").each do |a|
      link = a.css(".ozn1 a").first
      customer = a.css(".ozn2").text.strip
      description = a.css(".ozn3").text.strip

      announcements << { link: { text: link.text, href: link["href"] }, customer: customer, description: description }
    end

    [page_info, announcements]
  end
end