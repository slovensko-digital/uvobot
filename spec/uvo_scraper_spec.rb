require "spec_helper"
require "./uvo_scraper"

describe UvoScraper do
  let(:scraper) { UvoScraper.new }

  describe ".issue_ready?" do
    it "returns true if new issue is present" do
      stub_request(:any, UvoScraper::NEW_ISSUE_URL).
        to_return(body: File.new('./spec/support/fixtures/new_issue_uvo_page.html'), :status => 200)

      Timecop.freeze(Date.new(2016, 1, 25)) do
        expect(scraper.issue_ready?).to eq true
      end
    end

    it "returns false when new issue is missing" do
      stub_request(:any, UvoScraper::NEW_ISSUE_URL).
        to_return(body: File.new('./spec/support/fixtures/new_issue_missing_uvo_page.html'), :status => 200)

      Timecop.freeze(Date.new(2016, 1, 25)) do
        expect(scraper.issue_ready?).to eq false
      end
    end
  end

  describe ".announcements" do
    it "returns parsed announcements and page info" do
      stub_request(:any, UvoScraper::SEARCH_URL).
        to_return(body: File.new('./spec/support/fixtures/announcements.html'), :status => 200)

      page_info, announcements = scraper.announcements

      expect(page_info).to eq "Records 1 - 30 from 68."
      expect(announcements.count).to eq 2
      announcement = announcements.first

      link = { href: "link_1", text: "link 1 text" }
      expect(announcement[:link]).to eq link
      expect(announcement[:customer]).to eq "Company 1"
      expect(announcement[:description]).to eq "Title 1"
    end
  end
end
