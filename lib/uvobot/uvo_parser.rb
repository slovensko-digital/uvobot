require 'nokogiri'

module Uvobot
  class ParsingError < StandardError
  end

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
      # there are multiple formats of detail page, this method does not handle them all for now
      detail = {}
      h_doc = doc(html)
      amount_node = h_doc.xpath('//div[text()="Hodnota "]').css('span').first
      fail Uvobot::ParsingError, 'Amount node not found.' if amount_node.nil?

      detail[:amount] = amount_node.text
      detail
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
end