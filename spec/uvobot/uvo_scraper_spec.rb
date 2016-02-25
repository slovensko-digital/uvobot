require './lib/uvobot/uvo_scraper'
require './lib/uvobot/uvo_parser'
require 'date'

RSpec.describe Uvobot::UvoScraper do
  let(:curl_double) { double }
  let(:scraper) { Uvobot::UvoScraper.new(Uvobot::UvoParser, curl_double) }

  describe '.issue_ready?' do
    it 'returns true if new issue is present' do
      allow(curl_double).to receive_message_chain('get.body') do
        File.read('./spec/support/fixtures/new_issue_uvo_page.html')
      end
      expect(scraper.issue_ready?(Date.new(2016, 2, 2))).to eq true
    end

    it 'returns false when new issue is missing' do
      allow(curl_double).to receive_message_chain('get.body') do
        File.read('./spec/support/fixtures/new_issue_uvo_page.html')
      end
      scraper = Uvobot::UvoScraper.new(Uvobot::UvoParser, curl_double)
      expect(scraper.issue_ready?(Date.new(2016, 2, 3))).to eq false
    end

    it 'returns false when no issue found for date is displayed' do
      allow(curl_double).to receive_message_chain('get.body') do
        File.read('./spec/support/fixtures/issue_for_date_not_found_page.html')
      end
      scraper = Uvobot::UvoScraper.new(Uvobot::UvoParser, curl_double)
      expect(scraper.issue_ready?(Date.new(2016, 2, 3))).to eq false
    end

    it 'fails if the issue page is not valid (change of structure)' do
      allow(curl_double).to receive_message_chain('get.body') { '' }
      expect { scraper.issue_ready?(Date.new(2016, 2, 3)) }.to raise_error Uvobot::UvoScraper::InvalidIssuePage
    end
  end

  describe '.get_announcements' do
    it 'returns scraped announcements and page info' do
      allow(curl_double).to receive_message_chain('get.body') do
        File.read('./spec/support/fixtures/announcements.html')
      end

      page_info, announcements = scraper.get_announcements(Date.new(2016, 1, 29))

      expect(page_info).to eq '3 záznamov'
      expect(announcements.count).to eq 3
      announcement = announcements.first

      href = 'https://www.uvo.gov.sk/vestnik/oznamenie/detail/327310?page=1&limit=20&sort=datumZverejnenia&'\
        'sort-dir=DESC&ext=1&cisloOznamenia=&text=&year=0&dzOd=02.02.2016&dzDo=02.02.2016&cvestnik=&doznamenia=-1'\
        '&dzakazky=-1&dpostupu=-1&mdodania=&kcpv=48000000-8+72000000-5&opb=&szfeu=&flimit=-1&nobstaravatel=&nzakazky='
      link = { href: href, text: '2631 - ZSS' }
      expect(announcement[:link]).to eq link
      expect(announcement[:procurer]).to eq 'Slovenský plynárenský priemysel, akciová spoločnosť'
      expect(announcement[:procurement_subject]).to eq 'Dodávka, implementácia a následné služby k SW riešeniu '\
        'Treasury a Risk management'
    end
  end

  describe '.get_announcement_detail' do
    it 'parses out detail info' do
      allow(curl_double).to receive_message_chain('get.body') do
        File.read('./spec/support/fixtures/procurement_announcement_detail.html')
      end
      detail = {
        amount: '270 000,0000 EUR',
        procurement_type: 'Verejná súťaž',
        project_runtime: 'Obdobie v mesiacoch (od zadania zákazky) - Hodnota: 60',
        offer_placing_term: '21.03.2016 09:00'
      }
      expect(scraper.get_announcement_detail('dummy url')).to eq detail
    end

    it 'returns nil when parsing fails' do
      allow(curl_double).to receive_message_chain('get.body') do
        '<html><body><body/></html>'
      end
      expect(scraper.get_announcement_detail('dummy url')).to eq nil
    end
  end
end
