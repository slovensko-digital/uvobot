require './lib/uvo_scraper'
require './lib/uvo_parser'
require 'date'

RSpec.describe UvoScraper do
  let(:curl_double) { double }
  let(:scraper) { UvoScraper.new(UvoParser, curl_double) }

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
      scraper = UvoScraper.new(UvoParser, curl_double)
      expect(scraper.issue_ready?(Date.new(2016, 1, 29))).to eq false
    end
  end

  describe '.announcements' do
    it 'returns parsed announcements and page info' do
      allow(curl_double).to receive_message_chain('post.body') do
        File.read('./spec/support/fixtures/announcements.html')
      end
      page_info, announcements = scraper.get_announcements(Date.new(2016, 1, 29))

      expect(page_info).to eq 'Zobrazujem 5 záznamov.'
      expect(announcements.count).to eq 5
      announcement = announcements.first

      link = { href: 'https://www2.uvo.gov.sk/evestnik/-/vestnik/326817', text: '2329 - VZT' }
      expect(announcement[:link]).to eq link
      expect(announcement[:customer]).to eq 'Štatistický úrad Slovenskej republiky'
      expect(announcement[:description]).to eq 'Dodávka informačno-komunikačných technológií'
    end
  end
end
