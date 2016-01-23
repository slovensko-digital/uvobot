require 'curb'
require 'nokogiri'
require 'json'
require 'uri'
require 'dotenv'

Dotenv.load!

SEARCH_URL = 'https://www2.uvo.gov.sk/evestnik?p_p_id=evestnik_WAR_eVestnikPortlets&p_p_lifecycle=1&p_p_state=normal&p_p_mode=view&p_p_col_id=column-2&p_p_col_pos=1&p_p_col_count=2'
NEW_ISSUE_URL = 'https://www2.uvo.gov.sk/evestnik/-/vestnik/aktual'

def send_message(text)
  payload = { text: text, channel: '#general', username: 'uvobot', icon_emoji: ':mag_right:' }
  Curl.post(ENV['UVOBOT_SLACK_WEBHOOK'], payload.to_json)
end

def issue_ready?
  html = Curl.get(NEW_ISSUE_URL).body
  header = Nokogiri::HTML.parse(html).css('h1')[1]
  identifier = Time.now.strftime('/%Y - %-d.%-m.%Y')
  header.text.include?(identifier)
end

unless issue_ready?
  send_message('*Fíha, dnes na ÚVO nevyšlo nové vydanie vestníka?*')
  exit
end

today = Time.now.strftime('%d.%m.%Y')
vars = { cpv: 72, datumZverejneniaOd: today, datumZverejneniaDo: today}

html = Curl.post(SEARCH_URL, vars).body
doc = Nokogiri::HTML.parse(html)

rows = doc.css('.oznamenie')

if rows.count == 0 
  send_message('Dnes som nenašiel žiadne nové IT zákazky.')
else
  counter = doc.css('.search-results').first.text
  send_message("Našiel niečo nové na ÚVO! #{counter}")
end

rows.each do |row|
  link = row.css('.ozn1 a').first
  customer = row.css('.ozn2').text.strip
  description = row.css('.ozn3').text.strip

  send_message("<#{link['href']}|#{link.text}>: *#{customer}* #{description}")
end

