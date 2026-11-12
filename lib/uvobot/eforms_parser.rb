module Uvobot
  # Current eForms pages use labelled list items, unlike the legacy notice HTML.
  class EformsParser
    def initialize(node)
      @node = node
      @fields = Hash.new { |fields, label| fields[label] = [] }
      node.css('li').each do |item|
        label, separator, value = item.text.gsub(/[[:space:]]+/, ' ').strip.partition(':')
        @fields[label.strip] << value.strip unless separator.empty? || value.strip.empty?
      end
    end

    def parse
      details = {announcement_type: @node.at_css('h3.title').text.strip}
      case value('Typ formulára')
      when 'Výsledok'
        details.merge(
          amount: measure('Celková hodnota oznámenia (BT-161-NoticeResult)', 'mena'),
          procurement_type: value('Druh postupu'),
          procurement_winner: winner
        )
      when 'Súťaž'
        details.merge(
          amount: measure('Predpokladaná hodnota (BT-27-Procedure)', 'mena'),
          procurement_type: value('Druh postupu'),
          project_runtime: measure('Dĺžka trvania (BT-36-Lot)', 'jednotka'),
          proposal_placing_term: deadline
        )
      else
        details
      end
    end

    private

    def value(label)
      values = @fields[label].uniq
      values.first if values.one?
    end

    def measure(label, unit)
      amount = value("#{label} (hodnota)")
      [amount, value("#{label} (#{unit})")].compact.join(' ') if amount
    end

    def deadline
      date = value('Lehota na predkladanie ponúk (dátum)')
      [date, value('Lehota na predkladanie ponúk (čas)')].compact.join(' ') if date
    end

    def winner
      return if @fields['Identifikátor úspešnej ponuky'].empty?
      return unless @fields['Informácia, či bol vybratý víťaz'].include?('Bol vybratý aspoň jeden víťaz')

      # A notice may include losing bidders too. Only report the unambiguous
      # single-party case, not every organisation or the contract's signatory.
      names = @fields['ID uchádzača'].filter_map do |reference|
        reference[/\A(?:ORG|TPA)-\d+\s+\((.+)\)\z/, 1]
      end.uniq
      names.first if names.one?
    end
  end
end
