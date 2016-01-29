require './lib/slack_notifier'

RSpec.describe SlackNotifier do
  let(:curl_double) { double }
  let(:notifier) { SlackNotifier.new('slack.com', curl_double) }

  describe '.new_issue_not_published' do
    it 'sends correct payload to slack' do
      expect(curl_double).to receive(:post).with(*params('*Fíha, dnes na ÚVO nevyšlo nové vydanie vestníka?*'))
      notifier.new_issue_not_published
    end
  end

  describe '.matching_announcements_found' do
    let(:announcements) do
      [{ link: { text: 'text 1', href: 'href 1' }, procurer: 'procurer 1', procurement_subject: 'desc 1' }]
    end

    it 'sends correct payloads to slack' do
      expect(curl_double).to receive(:post).with(*params('Našiel som niečo nové na ÚVO! (Found 1 record)'))
      expect(curl_double).to receive(:post).with(*params('<href 1|text 1>: *procurer 1* desc 1'))
      notifier.matching_announcements_found('Found 1 record', announcements)
    end
  end

  describe '.no_announcements_found' do
    it 'sends correct payloads to slack' do
      expect(curl_double).to receive(:post).with(*params('Dnes som nenašiel žiadne nové IT zákazky.'))
      notifier.no_announcements_found
    end
  end
end

def params(message)
  ['slack.com', payload_json_string(message)]
end

def payload_json_string(message)
  {
    text: message,
    channel: '#general',
    username: 'uvobot',
    icon_emoji: ':mag_right:'
  }.to_json
end
