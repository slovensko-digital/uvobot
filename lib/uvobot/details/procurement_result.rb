module Uvobot
  module Details
    module ProcurementResult
      def parse_detail
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

      def procurement_winner
        xpath = '//span[contains(text(),"NÁZOV A ADRESA HOSPODÁRSKEHO SUBJEKTU, V PROSPECH KTORÉHO SA ROZHODLO")]'
        with_node(xpath) do |node|
          winner_address = node.parent.next.next.text.strip
          address_bits = winner_address.gsub(/:\s*/, ': ').split("\n").map(&:strip).delete_if { |l| l == '' }
          address_bits.join("\n")
        end
      end
    end
  end
end
