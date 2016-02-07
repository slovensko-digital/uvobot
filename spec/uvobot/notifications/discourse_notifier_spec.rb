require './lib/uvobot/notifications/discourse_notifier'

RSpec.describe Uvobot::Notifications::DiscourseNotifier do
  let(:client_double) { double }
  let(:scraper_double) { double }
  let(:client_exception_class_double) { double }
  let(:notifier) { Uvobot::Notifications::DiscourseNotifier.new(client_double, 'dummy category', scraper_double) }

  describe '.no_announcements_found' do
    it 'does nothing' do
      expect(notifier.no_announcements_found).to eq nil
    end
  end

  describe '.new_issue_not_published' do
    it 'does nothing' do
      expect(notifier.new_issue_not_published).to eq nil
    end
  end

  describe '.match_announcements_found' do
    it 'creates new topic for each announcement' do
      allow(client_double).to receive('create_topic') { true }
      allow(scraper_double).to receive('get_announcement_detail') { { amount: '1000 EUR' } }
      announcements = [{ link: { href: 'href', text: 'text' },
                         procurer: 'procurer',
                         procurement_subject: 'subject'
                       }]

      params = {
        title: 'subject',
        raw: "**Obstarávateľ:** procurer  \n**Predmet obstarávania:** subject" \
             "  \n**Cena:** 1000 EUR  \n**Zdroj:** [text](href)",
        category: 'dummy category'
      }
      expect(client_double).to receive(:create_topic).with(params)

      notifier.matching_announcements_found('page info', announcements)
    end

    it 'handles empty details' do
      allow(client_double).to receive('create_topic') { true }
      allow(scraper_double).to receive('get_announcement_detail') { nil }
      announcements = [{ link: { href: 'href', text: 'text' },
                         procurer: 'procurer',
                         procurement_subject: 'subject'
                       }]

      params = {
        title: 'subject',
        raw: "**Obstarávateľ:** procurer  \n**Predmet obstarávania:** subject" \
             "  \n**Detaily sa nepodarilo extrahovať.**  \n**Zdroj:** [text](href)",
        category: 'dummy category'
      }
      expect(client_double).to receive(:create_topic).with(params)

      notifier.matching_announcements_found('page info', announcements)
    end
  end
end
