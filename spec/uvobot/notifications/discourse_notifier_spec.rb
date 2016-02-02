require './lib/uvobot/notifications/discourse_notifier'

RSpec.describe Uvobot::Notifications::DiscourseNotifier do
  let(:client_double) { double }
  let(:client_exception_class_double) { double }
  let(:notifier) { Uvobot::Notifications::DiscourseNotifier.new(client_double, 'dummy category') }

  describe '.match_announcements_found' do
    it 'creates new topic for each announcement' do
      allow(client_double).to receive('create_topic') { true }
      announcements = [{ link: { href: 'href', text: 'text' },
                         procurer: 'procurer',
                         procurement_subject: 'subject',
                         detail: -> { { amount: '1000' } } }]

      params = {
        title: 'subject',
        raw: "**Obstarávateľ:** procurer  \n**Predmet obstarávania:** subject" \
             "  \n**Cena:** 1000 EUR  \n**Zdroj:** [text](href)",
        category: 'dummy category'
      }
      expect(client_double).to receive(:create_topic).with(params)

      notifier.matching_announcements_found('page info', announcements)
    end

    it 'handles validations errors' do
    end
  end

  describe '.no_announcements_found' do
  end

  describe '.new_issue_not_published' do
  end
end
