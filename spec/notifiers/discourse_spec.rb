require './lib/notifiers/discourse'

RSpec.describe Notifiers::Discourse do
  let(:client_double) { double }
  let(:client_exception_class_double) { double }
  let(:publisher) { Notifiers::Discourse.new(client_double, 'dummy category') }

  describe '.match_announcements_found' do
    it 'creates new topic for each announcement' do
      allow(client_double).to receive_message_chain('create_topic') { true }
      announcements = [{ link: { href: 'href', text: 'text' },
                         procurer: 'procurer', procurement_subject: 'subject', amount: '1000' }]

      params = {
        title: 'subject',
        raw: "**Obstarávateľ:** procurer  \n**Predmet obstarávania:** subject" \
             "  \n**Cena:** 1000 EUR  \n**Zdroj:** [text](href)",
        category: 'dummy category'
      }
      expect(client_double).to receive(:create_topic).with(params)

      publisher.matching_announcements_found('page info', announcements)
    end

    it 'handles validations errors' do
    end
  end

  describe '.no_announcements_found' do
  end

  describe '.new_issue_not_published' do
  end
end
