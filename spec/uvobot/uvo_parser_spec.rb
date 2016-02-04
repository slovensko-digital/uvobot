require './lib/uvobot/uvo_parser'

RSpec.describe Uvobot::UvoParser do
  let(:parser) { Uvobot::UvoParser }

  describe '.parse_announcements' do
    it 'parses out announcements in structured form' do
      html = File.read('./spec/support/fixtures/announcements.html')
      announcements = parser.parse_announcements(html)

      expect(announcements.count).to eq 5

      announcement = announcements.first
      link = { href: 'https://www2.uvo.gov.sk/evestnik/-/vestnik/326817', text: '2329 - VZT' }
      expect(announcement[:link]).to eq link
      expect(announcement[:procurer]).to eq 'Štatistický úrad Slovenskej republiky'
      expect(announcement[:procurement_subject]).to eq 'Dodávka informačno-komunikačných technológií'
    end
  end

  describe '.parse_detail' do
    it 'parses out announcement detail info' do
      html = File.read('./spec/support/fixtures/announcement_detail.html')
      detail = parser.parse_detail(html)
      expect(detail[:amount]).to eq '24 074,6800'
    end
  end

  describe '.parse_page_info' do
    it 'parses out string with pagination data' do
      html = File.read('./spec/support/fixtures/announcements.html')
      expect(parser.parse_page_info(html)).to eq 'Zobrazujem 5 záznamov.'
    end
  end

  describe '.parse_issue_header' do
    it 'parses out current issue header' do
      html = File.read('./spec/support/fixtures/new_issue_uvo_page.html')
      expect(parser.parse_issue_header(html)).to eq ' Vestník číslo 19/2016 - 28.1.2016 '
    end
  end
end
