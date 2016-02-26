require 'nokogiri'

module Uvobot
  module Details
    class Parser
      def initialize(html)
        @html_doc = Nokogiri::HTML(html)
      end

      def procurement_announcement
        {
          amount: amount,
          procurement_type: procurement_type,
          project_runtime: project_runtime,
          offer_placing_term: offer_placing_term
        }
      end

      def procurement_result
        {
          amount: amount,
          procurement_type: procurement_type,
          procurement_winner: procurement_winner
        }
      end

      def amount
        with_node('//div[text()="Hodnota            "]') do |node|
          node.css('span').map { |s| s.text.strip }.join(' ')
        end
      end

      def procurement_type
        with_node('//strong[starts-with(text(),"Druh postupu:")]') do |node|
          wrapper_div_text = node.parent.text
          wrapper_div_text.gsub('Druh postupu:', '').strip
        end
      end

      def offer_placing_term
        xpath = '//span[contains(text(),"Podmienky na získanie súťažných podkladov a doplňujúcich dokumentov")]'
        with_node(xpath) do |node|
          term_text = node.parent.next.next.next.next.text
          term_text.gsub("Dátum a čas: ", '')
        end
      end

      def project_runtime
        with_node('//span[contains(text(),"TRVANIE ZÁKAZKY ALEBO LEHOTA NA DOKONČENIE")]') do |node|
          label_text = node.parent.next.next.text
          value_text = node.parent.next.next.next.next.text
          "#{normalize_whitespace(label_text)} - #{normalize_whitespace(value_text)}"
        end
      end

      def procurement_winner
        xpath = '//span[contains(text(),"NÁZOV A ADRESA HOSPODÁRSKEHO SUBJEKTU, V PROSPECH KTORÉHO SA ROZHODLO")]'
        with_node(xpath) do |node|
          winner_address = node.parent.next.next.text.strip
          address_bits = winner_address.gsub(/:\s*/, ': ').split("\n").map(&:strip).delete_if { |l| l == '' }
          address_bits.join("\n")
        end
      end

      def with_node(xpath)
        node = @html_doc.at_xpath(xpath)
        return nil if node.nil?
        yield node
      end

      def normalize_whitespace(text)
        result = text.clone
        result.gsub!(/(\s){2,}/, '\\1')
        result.strip
      end
    end
  end
end
