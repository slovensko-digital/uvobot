require "nokogiri"

class UvoParser

  def initialize(html)
    @doc = Nokogiri::HTML(html)
  end

  def parse_announcements
    announcements = []

    @doc.css(".oznamenie").each do |a|
      link = a.css(".ozn1 a").first
      customer = a.css(".ozn2").text.strip
      description = a.css(".ozn3").text.strip

      announcements << { link: { text: link.text, href: link["href"] },
                         customer: customer, description: description }
    end
    announcements
  end

  def parse_page_info
   @doc.css(".search-results").first.text.strip
  end

  def parse_issue_header
    @doc.css("h1")[1].text
  end
end