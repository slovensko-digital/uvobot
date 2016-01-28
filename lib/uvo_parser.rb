require 'nokogiri'

class UvoParser
  def self.parse_announcements(html)
    announcements = []

    doc(html).css('.oznamenie').each do |a|
      link = a.css('.ozn1 a').first
      customer = a.css('.ozn2').text.strip
      description = a.css('.ozn3').text.strip

      announcements << {
        link: { text: link.text, href: link['href'] },
        customer: customer,
        description: description
      }
    end
    announcements
  end

  def self.parse_page_info(html)
    doc(html).css('.search-results').first.text.strip
  end

  def self.parse_issue_header(html)
    doc(html).css('h1')[1].text
  end

  def self.doc(html)
    Nokogiri::HTML(html)
  end
end
