require 'nokogiri'
require_relative 'procurement_result'
require_relative 'procurement_announcement'

module Uvobot
  module Details
    class Parser
      class DetailRecognitionError < StandardError
      end

      def initialize(html)
        @html_doc = Nokogiri::HTML(html)
        extend_instance_with(parse_type)
      end

      def extend_instance_with(module_name)
        extend Kernel.const_get("Uvobot::Details::#{module_name}")
      end

      def parse_type
        case type_header_text
        when 'OZNÁMENIE O VYHLÁSENÍ VEREJNÉHO OBSTARÁVANIA'
          'ProcurementAnnouncement'
        when 'OZNÁMENIE O VÝSLEDKU VEREJNÉHO OBSTARÁVANIA'
          'ProcurementResult'
        else
          raise DetailRecognitionError
        end
      end

      def type_header_text
        header = @html_doc.css('div.MainHeader')[1]
        header ? header.text.strip : nil
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
