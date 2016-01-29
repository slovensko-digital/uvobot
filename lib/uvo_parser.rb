require 'nokogiri'

class UvoParser
  def self.parse_announcements(html)
    announcements = []

    doc(html).css('.oznamenie').each do |a|
      link = a.css('.ozn1 a').first
      procurer = a.css('.ozn2').text.strip
      procurement_subject = a.css('.ozn3').text.strip

      announcements << {
        link: { text: link.text, href: link['href'] },
        procurer: procurer,
        procurement_subject: procurement_subject
      }
    end
    announcements
  end

  def self.parse_detail(html)
    detail = {amount: 'Parsing failed'}
    begin
      h_doc = doc(html)
      #TODO unstable, there are multiple formats of detail page
      detail[:amount] = h_doc.xpath('//div[text()="Hodnota "]').css('span').first.text
    rescue Exception => e
       puts e.message
    ensure
      return detail
    end
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
