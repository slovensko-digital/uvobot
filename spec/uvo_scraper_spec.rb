require "spec_helper"
require "./uvo_scraper"
require "./uvo_parser"
require "support/curl_double"

describe UvoScraper do
  let(:curl_double) { CurlDouble.new }
  let(:scraper) { UvoScraper.new(UvoParser, Date.new(2016, 1, 28), curl_double) }

  describe ".issue_ready?" do
    it "returns true if new issue is present" do
      curl_double.stubbed_get_body = File.open("./spec/support/fixtures/new_issue_uvo_page.html")
      expect(scraper.issue_ready?).to eq true
    end

    it "returns false when new issue is missing" do
      curl_double.stubbed_get_body = File.open("./spec/support/fixtures/new_issue_uvo_page.html")
      scraper = UvoScraper.new(UvoParser, Date.new(2016, 1, 29), curl_double)
      expect(scraper.issue_ready?).to eq false
    end
  end

  describe ".announcements" do
    it "returns parsed announcements and page info" do
      curl_double.stubbed_post_body = File.open("./spec/support/fixtures/announcements.html")
      page_info, announcements = scraper.get_announcements

      expect(page_info).to eq "Zobrazujem 5 záznamov."
      expect(announcements.count).to eq 5
      announcement = announcements.first

      link = { href: "https://www2.uvo.gov.sk/evestnik/-/vestnik/326817", text: "2329 - VZT" }
      expect(announcement[:link]).to eq link
      expect(announcement[:customer]).to eq "Štatistický úrad Slovenskej republiky"
      expect(announcement[:description]).to eq "Dodávka informačno-komunikačných technológií"
    end
  end
end
