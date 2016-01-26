require 'json'
require 'curb'

class SlackNotifier
  def initialize(slack_webhook)
    @slack_webhook = slack_webhook
  end

  def new_issue_not_published
    send_message('*Fíha, dnes na ÚVO nevyšlo nové vydanie vestníka?*')
  end

  def announcements_found(page, announcements)
    send_header_message(page, announcements)

    announcements.each do |a|
      send_message("<#{a[:link][:href]}|#{a[:link][:text]}>: *#{a[:customer]}* #{a[:description]}")
    end
  end

  private

  def send_header_message(page, announcements)
    if announcements.count > 0
      send_message("Našiel som niečo nové na ÚVO! (#{page})")
    else
      send_message('Dnes som nenašiel žiadne nové IT zákazky.')
    end
  end

  def send_message(text)
    Curl.post(@slack_webhook, payload(text))
  end

  def payload(text)
    { text: text,
      channel: '#general',
      username: 'uvobot',
      icon_emoji: ':mag_right:'
    }.to_json
  end
end