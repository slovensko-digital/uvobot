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
        procurement_type: parse_procurement_type(html),
        procurement_winner: parse_procurement_winner(html),
        offer_placing_term: parse_offer_placing_term(html),
        project_runtime: parse_project_runtime(html)
      }

      result.values.none? ? nil : result
    end

    def self.parse_amount(html)
      with_node(html, '//div[text()="Hodnota            "]') do |node|
        node.css('span').map { |s| s.text.strip }.join(' ')
      end
    end

    def self.parse_procurement_type(html)
      with_node(html, '//strong[starts-with(text(),"Druh postupu:")]') do |node|
        wrapper_div_text = node.parent.text
        wrapper_div_text.gsub('Druh postupu:', '').strip
      end
    end

    def self.parse_procurement_winner(html)
      xpath = '//span[contains(text(),"NÁZOV A ADRESA HOSPODÁRSKEHO SUBJEKTU, V PROSPECH KTORÉHO SA ROZHODLO")]'
      with_node(html, xpath) do |node|
        winner_address = node.parent.next.next.text.strip
        address_bits = winner_address.gsub(/:\n\s*/, ': ').split("\n").map(&:strip).delete_if { |l| l == '' }
        address_bits.join("\n")
      end
    end

    def self.parse_offer_placing_term(html)
      xpath = '//span[contains(text(),"Podmienky na získanie súťažných podkladov a doplňujúcich dokumentov")]'
      with_node(html, xpath) do |node|
        term_text = node.parent.next.next.next.next.text
        term_text.gsub("Dátum a čas: ", '')
      end
    end

    def self.parse_project_runtime(html)
      with_node(html, '//span[contains(text(),"TRVANIE ZÁKAZKY ALEBO LEHOTA NA DOKONČENIE")]') do |node|
        label_text = node.parent.next.next.text
        value_text = node.parent.next.next.next.next.text
        "#{normalize_whitespace(label_text)} - #{normalize_whitespace(value_text)}"
      end
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

    def self.with_node(html, xpath)
      node = doc(html).at_xpath(xpath)
      return nil if node.nil?
      yield node
    end

    def self.normalize_whitespace(text)
      result = text.clone
      result.gsub!(/(\s){2,}/, '\\1')
      result.strip
    end
  end
end
