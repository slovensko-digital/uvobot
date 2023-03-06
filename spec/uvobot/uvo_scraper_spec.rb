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

      href = 'https://www.uvo.gov.sk/vestnik-a-registre/vestnik/oznamenie/detail/326833?cHash=381e97f7c0e9ae95737d7282e3d329f8'
      link = { href: href, text: '2422 - VZT' }
      expect(announcement[:link]).to eq link
      expect(announcement[:procurer]).to eq 'Ministerstvo spravodlivosti Slovenskej republiky'
      expect(announcement[:procurement_subject]).to eq 'Dodávka HW, SW a súvisiacich služieb'
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
        announcement_type: "OZNÁMENIE O VYHLÁSENÍ VEREJNÉHO OBSTARÁVANIA",
        project_runtime: 'Obdobie v mesiacoch (od zadania zákazky) - Hodnota: 60',
        proposal_placing_term: '21.03.2016 09:00'
      }
      expect(scraper.get_announcement_detail('dummy url')).to eq detail
    end

    it 'returns only type with warning message when detail parsing fails' do
      allow(curl_double).to receive_message_chain('get.body') do
        '<html><body><body/></html>'
      end
      type_hash = { announcement_type: "Nepodarilo sa extrahovať typ oznamu." }
      expect(scraper.get_announcement_detail('dummy url')).to eq type_hash
    end
  end
end
