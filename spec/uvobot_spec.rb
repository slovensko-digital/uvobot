require "spec_helper"
require "./uvobot"
require "./slack_notifier"
require "./uvo_scraper"

describe Uvobot do
  let(:notifier) { SlackNotifier.new("https://hooks.slack.com") }
  let (:scraper) { UvoScraper.new }
  let(:bot) { Uvobot.new(notifier, scraper) }

  before :each do
    stub_request(:any, "https://hooks.slack.com")
  end

  describe ".run" do
    it "notifies missing issue" do
      allow(scraper).to receive(:issue_ready?).and_return(false)
      expect(notifier).to receive(:new_issue_not_published)
      bot.run
    end

    it "notifies matched announcements" do
      allow(scraper).to receive(:issue_ready?).and_return(true)
      allow(scraper).to receive(:announcements).and_return(["", []])
      expect(notifier).to receive(:matching_announcements).with("", [])
      bot.run
    end
  end
end