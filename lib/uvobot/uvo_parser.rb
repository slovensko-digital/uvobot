require 'nokogiri'

module Uvobot
  class UvoParser
    def self.parse_announcements(html, bulletin_url)
      announcements = []

      doc(html).css('#lists-table tr[onclick]').each do |tr|
        announcements << parse_table_line(tr, bulletin_url)
      end
      announcements
    end

    def self.parse_table_line(tr_node, bulletin_url)
      a_parts = tr_node.css('td').first.text.split("\n").map(&:strip)

      {
        link: { text: a_parts[0], href: parse_detail_link(tr_node, bulletin_url) },
        procurer: a_parts[1],
        procurement_subject: a_parts[2]
      }
    end

    def self.parse_detail_link(tr_node, bulletin_url)
      bulletin_url + tr_node.attributes['onclick'].text.scan(/'(.*)'/).first[0]
    end

    def self.parse_detail(html)
      # there are multiple formats of detail page, this method does not handle them all for now
      result = {
        amount: parse_amount(html),
        procurement_type: parse_procurement_type(html)
      }

      result.values.none? ? nil : result
    end

    def self.parse_amount(html)
      amount_nodes = doc(html).xpath('//div[text()="Hodnota            "]')
      return nil if amount_nodes.count == 0

      amount_nodes.first.css('span').map { |s| s.text.strip }.join(' ')
    end

    def self.parse_procurement_type(html)
      type_nodes = doc(html).xpath('//strong[starts-with(text(),"Druh postupu:")]')
      return nil if type_nodes.count == 0

      wrapper_div_text = type_nodes.first.parent.text
      wrapper_div_text.gsub('Druh postupu:', '').strip
    end

    def self.parse_page_info(html)
      page_info_node = doc(html).css('div.pag-info span').first
      page_info_node.nil? ? nil : page_info_node.text.strip
    end

    def self.parse_issue_header(html)
      doc(html).css('h1').text
    end

    def self.issue_page_valid?(html)
      h_doc = doc(html)
      header = h_doc.xpath('//h1[starts-with(text(), "Vestník")]').first
      no_issue_found_message = h_doc.xpath('//p[starts-with(text(), "Vestník podla zadaných")]').first

      header || no_issue_found_message
    end

    def self.doc(html)
      Nokogiri::HTML(html)
    end
  end
end
