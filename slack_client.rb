require 'json'
require 'curb'

class SlackClient
  def initialize(slack_webhook: nil)
    fail "Missing Slack webhook url." if slack_webhook.nil?
    @slack_webhook = slack_webhook
  end

  def send_message(text)
    Curl.post(@slack_webhook, payload(text))
  end

  private

  def payload(text)
    { text: text,
      channel: '#general',
      username: 'uvobot',
      icon_emoji: ':mag_right:'
    }.to_json
  end
end