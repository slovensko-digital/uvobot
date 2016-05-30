require './lib/uvobot/notifications/discourse_notifier'

RSpec.describe Uvobot::Notifications::DiscourseNotifier do
  let(:client_double) { double }
  let(:scraper_double) { double }
  let(:notifier) { Uvobot::Notifications::DiscourseNotifier.new(client_double, 'dummy category', scraper_double) }

  describe '.no_announcements_found' do
    it 'does nothing' do
      expect(notifier.no_announcements_found).to be_nil
    end
  end

  describe '.new_issue_not_published' do
    it 'does nothing' do
      expect(notifier.new_issue_not_published).to be_nil
    end
  end

  describe '.match_announcements_found' do
    it 'creates new topic for each announcement' do
      allow(client_double).to receive('create_topic') { true }
      allow(scraper_double).to receive('get_announcement_detail') do
        {
          amount: '1000 EUR',
          procurement_type: nil,
          project_runtime: 'runtime',
          proposal_placing_term: 'term',
          procurement_winner: 'winner',
          procurement_id: 123,
        }
      end
      announcements = [{
                         link: { href: 'href', text: 'text' },
                         procurer: 'procurer',
                         procurement_subject: 'subject'
                       }]

      params = {
        title: 'subject',
        raw: "**Obstarávateľ:** procurer  \n**Predmet obstarávania:** subject  \n**Cena:** 1000 EUR" \
             "  \n**Trvanie projektu:** runtime" \
             "  \n**Lehota na predkladanie ponúk:** term  \n**Víťaz obstarávania:**  \n winner" \
             "  \n**Zdroj:** [text](href)",
        category: 'dummy category',
        procurement_id: 123
      }

      expect(client_double).to receive(:create_topic).with(params)

      notifier.matching_announcements_found('page info', announcements)
    end
  end
end
