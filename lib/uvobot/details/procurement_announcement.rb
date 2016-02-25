module Uvobot
  module Details
    module ProcurementAnnouncement
      def parse_detail
        {
          amount: amount,
          procurement_type: procurement_type,
          offer_placing_term: offer_placing_term,
          project_runtime: project_runtime
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
    end
  end
end
