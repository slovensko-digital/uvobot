require 'spec_helper'
require './lib/uvobot'
require './lib/slack_notifier'
require './lib/uvo_scraper'

RSpec.describe Uvobot do
  describe '.run' do
    let(:notifier) { double }
    let(:scraper) { double }
    let(:bot) { Uvobot.new(notifier, scraper) }

    it 'notifies missing issue' do
      allow(scraper).to receive('issue_ready?') { false }
      expect(notifier).to receive(:new_issue_not_published)
      bot.run(nil)
    end

    it 'notifies no announcements found' do
      allow(scraper).to receive('issue_ready?') { true }
      allow(scraper).to receive('get_announcements') { ['', []] }
      expect(notifier).to receive(:no_announcements_found)
      bot.run(nil)
    end

    it 'notifies announcements found' do
      allow(scraper).to receive('issue_ready?') { true }
      allow(scraper).to receive('get_announcements') do
        ['', [{}, {}]]
      end
      expect(notifier).to receive(:matching_announcements_found).with('', [{}, {}])
      bot.run(nil)
    end
  end
end
