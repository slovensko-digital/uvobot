require 'dotenv'
require './slack_client'
require './uvo_scraper'

Dotenv.load!

class Uvobot
  def initialize(urls)
    @slack = SlackClient.new(slack_webhook: ENV['UVOBOT_SLACK_WEBHOOK'])
    @scraper = UvoScraper.new(urls)
  end

  def update
     if @scraper.issue_ready?
       announcements = @scraper.announcements
       @slack.send_message("Našiel som niečo nové na ÚVO!") if announcements.count > 0

       announcements.each do |a|
         @slack.send_message("<#{a[:link][:href]}|#{a[:link][:text]}>: *#{a[:customer]}* #{a[:description]}")
       end
     else
       @slack.send_message('*Fíha, dnes na ÚVO nevyšlo nové vydanie vestníka?*')
     end
  end
end

urls = {
  search:  'https://www2.uvo.gov.sk/evestnik?p_p_id=evestnik_WAR_eVestnikPortlets&p_p_lifecycle=1&p_p_state=normal&p_p_mode=view&p_p_col_id=column-2&p_p_col_pos=1&p_p_col_count=2',
  new_issue: 'https://www2.uvo.gov.sk/evestnik/-/vestnik/aktual'
}

Uvobot.new(urls).update