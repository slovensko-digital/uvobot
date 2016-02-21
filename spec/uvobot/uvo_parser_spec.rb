require './lib/uvobot/uvo_parser'

RSpec.describe Uvobot::UvoParser do
  let(:parser) { Uvobot::UvoParser }

  describe '.parse_announcements' do
    it 'parses out announcements in structured form' do
      html = File.read('./spec/support/fixtures/announcements.html')
      announcements = parser.parse_announcements(html, 'https://www.uvo.gov.sk')

      expect(announcements.count).to eq 3

      announcement = announcements.first
      href = 'https://www.uvo.gov.sk/vestnik/oznamenie/detail/327310?page=1&limit=20&sort=datumZverejnenia'\
        '&sort-dir=DESC&ext=1&cisloOznamenia=&text=&year=0&dzOd=02.02.2016&dzDo=02.02.2016&cvestnik=&'\
        'doznamenia=-1&dzakazky=-1&dpostupu=-1&mdodania=&kcpv=48000000-8+72000000-5&opb=&szfeu=&flimit=-1'\
        '&nobstaravatel=&nzakazky='
      link = { href: href, text: '2631 - ZSS' }
      expect(announcement[:link]).to eq link
      expect(announcement[:procurer]).to eq 'Slovenský plynárenský priemysel, akciová spoločnosť'
      expect(announcement[:procurement_subject]).to eq 'Dodávka, implementácia a následné služby k SW riešeniu '\
        'Treasury a Risk management'
    end
  end

  describe '.parse_detail' do
    it 'parses out announcement detail info' do
      html = File.read('./spec/support/fixtures/announcement_detail.html')
      detail = parser.parse_detail(html)
      expect(detail[:amount]).to eq '270 000,0000 EUR'
      expect(detail[:procurement_type]).to eq 'Verejná súťaž'
    end

    it 'returns nil if no detail info was found' do
      expect(parser.parse_detail('')).to eq nil
    end
  end

  describe '.parse_page_info' do
    it 'parses out string with pagination data' do
      html = File.read('./spec/support/fixtures/announcements.html')
      expect(parser.parse_page_info(html)).to eq '3 záznamov'
    end

    it 'returns nil when the page info section is missing' do
      html = '<html></html>'
      expect(parser.parse_page_info(html)).to eq nil
    end
  end

  describe '.parse_issue_header' do
    it 'parses out current issue header' do
      html = File.read('./spec/support/fixtures/new_issue_uvo_page.html')
      expect(parser.parse_issue_header(html)).to eq 'Vestník číslo 22/2016 - 02.02.2016'
    end
  end
end
