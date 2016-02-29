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
    it 'parses out procurement announcement detail info' do
      html = File.read('./spec/support/fixtures/procurement_announcement_detail.html')
      detail = parser.parse_detail(html)
      expect(detail[:amount]).to eq '270 000,0000 EUR'
      expect(detail[:procurement_type]).to eq 'Verejná súťaž'
      expect(detail[:proposal_placing_term]).to eq '21.03.2016 09:00'
      expect(detail[:project_runtime]).to eq 'Obdobie v mesiacoch (od zadania zákazky) - Hodnota: 60'
    end

    it 'parses out procurement result detail info' do
      html = File.read('./spec/support/fixtures/procurement_result_announcement_detail.html')
      detail = parser.parse_detail(html)
      expect(detail[:amount]).to eq '183 613,5000 EUR'
      expect(detail[:procurement_type]).to eq 'Verejná súťaž'
      winner_address = ['Aliter Technologies, a.s.',
                        'Vnútroštátne identifikačné číslo: 36831221',
                        'Turčianska 16 , 82109 Bratislava',
                        'Slovensko',
                        'Telefón: +421 255646350'].join("\n")
      expect(detail[:procurement_winner]).to eq winner_address
    end

    it 'parses out procurement addendum announcement detail info' do
      html = File.read('./spec/support/fixtures/procurement_addendum_announcement_detail.html')
      detail = parser.parse_detail(html)
      expect(detail[:procurement_type]).to eq 'Verejná súťaž'
    end

    it 'parses out call for proposals detail info' do
      html = File.read('./spec/support/fixtures/call_for_proposals_detail.html')
      detail = parser.parse_detail(html)
      expect(detail[:amount]).to eq 'Hodnota/Od: 180 000,0000 Do: 205 000,0000 EUR'
      expect(detail[:proposal_placing_term]).to eq '10.02.2016 10:00'
      expect(detail[:project_contract_runtime]).to eq 'Obdobie v mesiacoch (od zadania zákazky) - Zadajte hodnotu: 48'
    end

    it 'parses out concluded contract detail info' do
      html = File.read('./spec/support/fixtures/concluded_contract_info_detail.html')
      detail = parser.parse_detail(html)
      amount = 'Hodnota 147 202,4000 EUR - Bez DPH - Pri hodnote za rok alebo za mesiac uveďte Počet rokov - Hodnota: 3'
      expect(detail[:amount]).to eq amount
      winner_address = ['ArcGEO Information Systems spol. s r.o.',
                        'IČO: 31354882',
                        'Blagoevova 9 , 85104 Bratislava',
                        'Slovensko',
                        'Telefón: +421 249203701',
                        'Email: info@arcgeo.sk'].join("\n")
      expect(detail[:procurement_winner]).to eq winner_address
    end

    it 'returns extraction failure message when the detail parsing failed' do
      type_hash = { announcement_type: "Nepodarilo sa extrahovať nadpis detailu." }
      expect(parser.parse_detail('')).to eq type_hash
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
