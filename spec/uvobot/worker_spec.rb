require './lib/uvobot/worker'
require './lib/uvobot/uvo_scraper'

RSpec.describe Uvobot::Worker do
  describe '.run' do
    let(:notifier) { double }
    let(:scraper) { double }
    let(:bot) { Uvobot::Worker.new(scraper, [notifier]) }

    it 'notifies missing issue' do
      allow(scraper).to receive('issue_ready?') { { result: false } }
      expect(notifier).to receive(:new_issue_not_published)
      bot.run(Date.new(2016, 2, 5))
    end

    it 'mutes notification of missing issue on weekend' do
      allow(scraper).to receive('issue_ready?') { { result: false } }

      expect(notifier).to_not receive(:new_issue_not_published)
      saturday = Date.new(2016, 2, 6)
      bot.run(saturday)

      expect(notifier).to_not receive(:new_issue_not_published)
      sunday = Date.new(2016, 2, 7)
      bot.run(sunday)
    end

    it 'notifies no announcements found' do
      allow(scraper).to receive('issue_ready?') { { result: true } }
      allow(scraper).to receive('get_announcements') do
        ['', []]
      end
      expect(notifier).to receive(:no_announcements_found)
      bot.run(nil)
    end

    it 'notifies announcements found' do
      allow(scraper).to receive('issue_ready?') { { result: true } }
      allow(scraper).to receive('get_announcements') do
        ['', [{}, {}]]
      end
      expect(notifier).to receive(:matching_announcements_found).with('', [{}, {}])
      bot.run(nil)
    end
  end
end
