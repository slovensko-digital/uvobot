require './lib/uvobot/uvo_scraper'
require './lib/uvobot/uvo_parser'
require 'date'

RSpec.describe Uvobot::UvoScraper do
  let(:curl_double) { double }
  let(:scraper) { Uvobot::UvoScraper.new(Uvobot::UvoParser, curl_double) }

  def stub_html_response(body, code: 200)
    allow(curl_double).to receive(:get).and_return(double(body: body, code: code))
  end

  describe '.issue_ready?' do
    it 'returns true if new issue is present' do
      stub_html_response(File.read('./spec/support/fixtures/new_issue_uvo_page.html'))
      expect(scraper.issue_ready?(Date.new(2016, 2, 2))).to eq true
    end

    it 'returns false when new issue is missing' do
      stub_html_response(File.read('./spec/support/fixtures/new_issue_uvo_page.html'))
      scraper = Uvobot::UvoScraper.new(Uvobot::UvoParser, curl_double)
      expect(scraper.issue_ready?(Date.new(2016, 2, 3))).to eq false
    end

    it 'returns false when no issue found for date is displayed' do
      stub_html_response(File.read('./spec/support/fixtures/issue_for_date_not_found_page.html'))
      scraper = Uvobot::UvoScraper.new(Uvobot::UvoParser, curl_double)
      expect(scraper.issue_ready?(Date.new(2016, 2, 3))).to eq false
    end

    it 'fails if the issue page is not valid (change of structure)' do
      stub_html_response('')
      expect { scraper.issue_ready?(Date.new(2016, 2, 3)) }.to raise_error Uvobot::UvoScraper::InvalidIssuePage
    end

    it 'reports an HTTP failure rather than a missing issue' do
      stub_html_response('Service unavailable', code: 503)
      expect { scraper.issue_ready?(Date.new(2026, 11, 11)) }
        .to raise_error(Uvobot::UvoScraper::RequestFailed, /HTTP 503/)
    end
  end

  describe '.get_announcements' do
    it 'returns scraped announcements and page info' do
      html = File.read('./spec/support/fixtures/announcements.html')
      codes = Uvobot::UvoScraper::IT_CONTRACTS_CODES.join('+')
      url = "#{Uvobot::UvoScraper::SEARCH_URL}?a=listNotice&kcpv=#{codes}&dzOd=29.01.2016&dzDo=30.01.2016"
      expect(curl_double).to receive(:get).with(url, verify: false, timeout: 30)
        .and_return(double(code: 200, body: html))

      page_info, announcements = scraper.get_announcements(Date.new(2016, 1, 29))

      expect(page_info).to eq '3 záznamov'
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

    it 'reads current server-rendered results without a browser' do
      stub_html_response(File.read('./spec/support/fixtures/current_announcements.html'))
      page_info, announcements = scraper.get_announcements(Date.new(2026, 11, 11))

      expect(page_info).to eq '1 záznamov'
      expect(announcements.size).to eq 1
      expect(announcements.first).to include(
        procurer: 'Národná diaľničná spoločnosť, a.s.',
        procurement_subject: 'Obnova a rozšírenie nástroja na monitoring zraniteľnosti IP adresného priestoru a správu'
      )
      expect(announcements.first[:link][:href]).to eq(
        'https://www.uvo.gov.sk/vestnik-a-registre/vestnik/oznamenie/detail/1424997?cHash=43c748aa0ed07ab9eb579fb6a62d02cd'
      )
    end

    it 'reports forbidden responses instead of returning no announcements' do
      stub_html_response('Forbidden', code: 403)
      expect { scraper.get_announcements(Date.new(2026, 11, 11)) }
        .to raise_error(Uvobot::UvoScraper::RequestFailed, /HTTP 403/)
    end

    it 'rejects a successful response that does not contain the results table' do
      stub_html_response('<html><body>Unexpected page</body></html>')
      expect { scraper.get_announcements(Date.new(2026, 11, 11)) }
        .to raise_error(Uvobot::UvoScraper::InvalidAnnouncementsPage, /lists-table/)
    end

    it 'accepts a genuinely empty results table' do
      stub_html_response('<div class="pag-info"><span>0 záznamov</span></div><table id="lists-table"></table>')
      expect(scraper.get_announcements(Date.new(2026, 11, 11))).to eq ['0 záznamov', []]
    end
  end

  describe '.get_announcement_detail' do
    it 'parses out detail info' do
      stub_html_response(File.read('./spec/support/fixtures/procurement_announcement_detail.html'))
      detail = {
        amount: '270 000,0000 EUR',
        procurement_type: 'Verejná súťaž',
        announcement_type: "OZNÁMENIE O VYHLÁSENÍ VEREJNÉHO OBSTARÁVANIA",
        project_runtime: 'Obdobie v mesiacoch (od zadania zákazky) - Hodnota: 60',
        proposal_placing_term: '21.03.2016 09:00'
      }
      expect(scraper.get_announcement_detail('dummy url')).to eq detail
    end

    it 'returns only type with warning message when detail parsing fails' do
      stub_html_response('<html><body><body/></html>')
      type_hash = { announcement_type: "Nepodarilo sa extrahovať typ oznamu." }
      expect(scraper.get_announcement_detail('dummy url')).to eq type_hash
    end

    it 'does not parse an HTTP error as an announcement detail' do
      stub_html_response('Forbidden', code: 403)
      expect { scraper.get_announcement_detail('https://www.uvo.gov.sk/detail') }
        .to raise_error(Uvobot::UvoScraper::RequestFailed, /HTTP 403/)
    end
  end
end
