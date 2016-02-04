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
      expect(scraper.issue_ready?(Date.new(2016, 1, 28))).to eq true
    end

    it 'returns false when new issue is missing' do
      allow(curl_double).to receive_message_chain('get.body') do
        File.read('./spec/support/fixtures/new_issue_uvo_page.html')
      end
      scraper = Uvobot::UvoScraper.new(Uvobot::UvoParser, curl_double)
      expect(scraper.issue_ready?(Date.new(2016, 1, 29))).to eq false
    end
  end

  describe '.get_announcements' do
    it 'returns scraped announcements and page info' do
      allow(curl_double).to receive_message_chain('post.body') do
        File.read('./spec/support/fixtures/announcements.html')
      end

      page_info, announcements = scraper.get_announcements(Date.new(2016, 1, 29))

      expect(page_info).to eq 'Zobrazujem 5 záznamov.'
      expect(announcements.count).to eq 5
      announcement = announcements.first

      link = { href: 'https://www2.uvo.gov.sk/evestnik/-/vestnik/326817', text: '2329 - VZT' }
      expect(announcement[:link]).to eq link
      expect(announcement[:procurer]).to eq 'Štatistický úrad Slovenskej republiky'
      expect(announcement[:procurement_subject]).to eq 'Dodávka informačno-komunikačných technológií'
    end
  end

  describe '.get_announcement_detail' do
    it 'parses out detail info' do
      allow(curl_double).to receive_message_chain('get.body') do
        File.read('./spec/support/fixtures/announcement_detail.html')
      end
      detail = { amount: '24 074,6800' }
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
