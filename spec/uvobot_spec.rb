require "spec_helper"
require "./lib/uvobot"
require "./lib/slack_notifier"
require "./lib/uvo_scraper"

describe Uvobot do
  describe ".run" do
    let(:notifier) { double }
    let(:scraper) { double }
    let(:bot) { Uvobot.new(notifier, scraper) }

    it "notifies missing issue" do
      allow(scraper).to receive_message_chain("issue_ready?") { false }
      expect(notifier).to receive(:new_issue_not_published)
      bot.run("dummy date")
    end

    it "notifies no announcements found" do
      allow(scraper).to receive_message_chain("issue_ready?") { true }
      allow(scraper).to receive_message_chain("get_announcements") { ["", []] }
      expect(notifier).to receive(:no_announcements_found)
      bot.run("dummy date")
    end

    it "notifies announcements found" do
      allow(scraper).to receive_message_chain("issue_ready?") { true }
      allow(scraper).to receive_message_chain("get_announcements") do
        ["", [{}, {}]]
      end
      expect(notifier).to receive(:matching_announcements_found).with("",
                                                                      [{}, {}])
      bot.run("dummy date")
    end
  end
end
