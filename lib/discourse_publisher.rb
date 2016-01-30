class DiscoursePublisher
  def initialize(discourse_client)
    @client = discourse_client
  end

  def publish_announcements(announcements, category = 'Štátne projekty')
    announcements.each do |a|
      begin
        topic = announcement_to_topic(a)
        @client.create_topic(title: topic[:title],
                             raw: topic[:body],
                             category: category)
      rescue @client.class::Error => e
        # discourse api/faraday bug - most probably
        next if e.message == "757: unexpected token at 'null'"
        # TODO, discourse validation and rate violations handling
        puts e.message
      end
    end
  end

  def announcement_to_topic(announcement)
    {
      title: announcement[:procurement_subject].to_s,
      body: "**Obstarávateľ:** #{announcement[:procurer]}  \n" \
             "**Predmet obstarávania:** #{announcement[:procurement_subject]}  \n" \
             "**Cena:** #{announcement[:amount]} EUR  \n" \
             "**Zdroj:** [#{announcement[:link][:text]}](#{announcement[:link][:href]})"
    }
  end
end
