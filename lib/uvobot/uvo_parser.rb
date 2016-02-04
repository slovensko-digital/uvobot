require 'nokogiri'

module Uvobot
  class UvoParser
    def self.parse_announcements(html, root_url)
      announcements = []

      doc(html).css('#lists-table tr[onclick]').each do |e|
        items = e.css('td').first.text.split("\n").map(&:strip)
        link_text = items[0]
        link_href = e.attributes['onclick'].text.scan(/'(.*)'/).first[0]
        procurer = items[1]
        procurement_subject = items[2]

        announcements << {
          link: { text: link_text, href: root_url + link_href },
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
      amount_node = h_doc.xpath('//div[text()="Hodnota            "]').css('span').first
      return nil if amount_node.nil?

      detail[:amount] = amount_node.text
      detail
    end

    def self.parse_page_info(html)
      page_info_node = doc(html).css('div.pag-info span').first
      page_info_node.nil? ? nil : page_info_node.text.strip
    end

    def self.parse_issue_header(html)
      doc(html).css('h1').text
    end

    def self.doc(html)
      Nokogiri::HTML(html)
    end
  end
end
