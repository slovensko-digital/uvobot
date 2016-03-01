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

    # rubocop:disable Metrics/MethodLength
    def self.parse_detail(html)
      announcement_type = parse_announcement_type(html)
      result = case announcement_type
               when 'OZNÁMENIE O VYHLÁSENÍ VEREJNÉHO OBSTARÁVANIA'
                 parse_procurement_announcement(html)
               when 'OZNÁMENIE O VÝSLEDKU VEREJNÉHO OBSTARÁVANIA'
                 parse_procurement_result(html)
               when 'OZNÁMENIE O DODATOČNÝCH INFORMÁCIÁCH, INFORMÁCIÁCH O NEUKONČENOM KONANÍ ALEBO KORIGENDE'
                 parse_addendum_announcement(html)
               when 'VÝZVA NA PREDKLADANIE PONÚK (PODLIMITNÉ ZÁKAZKY)'
                 parse_call_for_proposals(html)
               when 'INFORMÁCIA O UZAVRETÍ ZMLUVY (PODLIMITNÉ ZÁKAZKY)'
                 parse_concluded_contract_info(html)
               else
                 {}
               end
      result[:announcement_type] = announcement_type
      result
    end

    def self.parse_announcement_type(html)
      header = doc(html).css('div.MainHeader')[1]
      header ? header.text.strip : 'Nepodarilo sa extrahovať typ oznamu.'
    end

    def self.parse_procurement_announcement(html)
      {
        amount: parse_amount(html),
        procurement_type: parse_procurement_type(html),
        project_runtime: parse_project_runtime(html),
        proposal_placing_term: parse_proposal_placing_term(html)
      }
    end

    def self.parse_procurement_result(html)
      {
        amount: parse_amount(html),
        procurement_type: parse_procurement_type(html),
        procurement_winner: parse_procurement_winner(html)
      }
    end

    def self.parse_addendum_announcement(html)
      {
        procurement_type: parse_procurement_type(html)
      }
    end

    def self.parse_call_for_proposals(html)
      {
        amount: parse_amount_interval(html),
        proposal_placing_term: parse_proposal_placing_term(html),
        project_contract_runtime: parse_contract_runtime(html)
      }
    end

    def self.parse_concluded_contract_info(html)
      {
        amount: parse_contract_amount(html),
        procurement_winner: parse_contract_winner(html)
      }
    end

    def self.parse_amount(html)
      with_node(html, '//div[text()="Hodnota            "]') do |node|
        node.css('span').map { |s| s.text.strip }.join(' ')
      end
    end

    def self.parse_amount_interval(html)
      with_node(html, '//div[starts-with(text(),"Hodnota/Od:")]') do |node|
        normalize_whitespace(node.text.tr("\n", ' '))
      end
    end

    def self.parse_contract_amount(html)
      with_node(html, '//span[contains(text(),"Informácie o hodnote zmluvy")]') do |node|
        parent = node.parent
        # real contract amount can have multiple lines
        amount_texts = append_siblings_texts(parent, []).delete_if { |t| t.strip == '' }
        normalize_whitespace(amount_texts.join(' - '))
      end
    end

    def self.parse_procurement_type(html)
      with_node(html, '//strong[starts-with(text(),"Druh postupu:")]') do |node|
        wrapper_div_text = node.parent.text
        wrapper_div_text.gsub('Druh postupu:', '').strip
      end
    end

    def self.parse_proposal_placing_term(html)
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

    def self.parse_contract_runtime(html)
      with_node(html, '//span[contains(text(),"Trvanie zmluvy alebo lehota dodania")]') do |node|
        label_text = node.parent.next.next.text
        value_text = node.parent.next.next.next.text
        "#{normalize_whitespace(label_text)} - #{normalize_whitespace(value_text)}"
      end
    end

    def self.parse_procurement_winner(html)
      xpath = '//span[contains(text(),"NÁZOV A ADRESA HOSPODÁRSKEHO SUBJEKTU, V PROSPECH KTORÉHO SA ROZHODLO")]'
      with_node(html, xpath) do |node|
        normalize_winner_address(node.parent.next.next)
      end
    end

    def self.parse_contract_winner(html)
      xpath = '//span[contains(text(),"Názov a adresa dodávateľa s ktorým sa uzatvorila zmluva")]'
      with_node(html, xpath) do |node|
        normalize_winner_address(node.parent.next.next)
      end
    end

    def self.normalize_winner_address(address_node)
      winner_address = address_node.text.strip
      address_bits = winner_address.gsub(/:\s*/, ': ').split("\n").map(&:strip).delete_if { |l| l == '' }
      address_bits.join("\n")
    end

    def self.with_node(html, xpath)
      node = doc(html).at_xpath(xpath)
      return nil if node.nil?
      yield node
    end

    def self.append_siblings_texts(node, texts)
      return texts if node.next.nil?
      sibling = node.next
      texts << sibling.text
      append_siblings_texts(sibling, texts)
    end

    def self.normalize_whitespace(text)
      result = text.clone
      result.gsub!(/(\s){2,}/, '\\1')
      result.strip
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
