require './lib/discourse_publisher'

RSpec.describe DiscoursePublisher do
  let(:client_double) { double}
  let(:client_exception_class_double) { double}
  let(:publisher) { DiscoursePublisher.new(client_double, client_exception_class_double) }

  describe '.publish_announcements' do
    it 'creates new topic for each announcement' do
      allow(client_double).to receive_message_chain('create_topic') { true }
      announcements = [{link: {href: 'href', text: 'text'},
                        procurer: 'procurer', procurement_subject: 'subject', amount: '1000'}]
      expect(client_double).to receive(:create_topic).with({:title=>"subject",
                                                            :raw=>"**Obstarávateľ:** procurer  \n**Predmet obstarávania:** subject" \
                                                            "  \n**Cena:** 1000 EUR  \n**Zdroj:** [text](href)",
                                                            :category=>"dummy category"})

      publisher.publish_announcements(announcements, 'dummy category')

    end

    it 'handles validations errors' do

    end
  end

end