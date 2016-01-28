require "spec_helper"
require "./uvo_parser"

describe UvoParser do
  let(:parser) { UvoParser }

  describe ".parse_announcements" do
    it "parses out announcements in structured form" do
      html = File.open("./spec/support/fixtures/announcements.html")
      announcements = parser.new(html).parse_announcements

      expect(announcements.count).to eq 5

      announcement = announcements.first
      link = { href: "https://www2.uvo.gov.sk/evestnik/-/vestnik/326817", text: "2329 - VZT" }
      expect(announcement[:link]).to eq link
      expect(announcement[:customer]).to eq "Štatistický úrad Slovenskej republiky"
      expect(announcement[:description]).to eq "Dodávka informačno-komunikačných technológií"
    end
  end

  describe ".parse_page_info" do
    it "parses out string with pagination data" do
      html = File.open("./spec/support/fixtures/announcements.html")
      expect(parser.new(html).parse_page_info).to eq "Zobrazujem 5 záznamov."
    end
  end

  describe ".parse_issue_header" do
    it "parses out current issue header" do
      html = File.open("./spec/support/fixtures/new_issue_uvo_page.html")
      expect(parser.new(html).parse_issue_header).to eq " Vestník číslo 19/2016 - 28.1.2016 "
    end
  end
end
