require 'curb'
require 'nokogiri'

class UvoScraper
  def initialize(urls)
   @urls = urls
  end

  def issue_ready?
    html = Curl.get(@urls[:new_issue]).body
    header = Nokogiri::HTML.parse(html).css('h1')[1]
    identifier = Time.now.strftime('/%Y - %-d.%-m.%Y')
    header.text.include?(identifier)
  end

  def announcements
    result = []
    today = Time.now.strftime('%d.%m.%Y')

    # cpv=72 filters out only IT related announcements
    search_query = { cpv: 72, datumZverejneniaOd: today, datumZverejneniaDo: today}

    html = Curl.post(@urls[:search], search_query).body
    doc = Nokogiri::HTML.parse(html)

    doc.css('.oznamenie').each do |a|
      link = a.css('.ozn1 a').first
      customer = a.css('.ozn2').text.strip
      description = a.css('.ozn3').text.strip

      result << {link: {text: link.text, href: link['href']}, customer: customer, description: description}
    end
    result
  end
end