require './lib/uvobot/discourse_client'

RSpec.describe Uvobot::DiscourseClient do
  let(:client) { Uvobot::DiscourseClient.new('http://foobar.com', '12345', 'foo') }
  describe '.create_topic' do
    it 'returns nil when discourse gem exception is rescued' do
      allow_any_instance_of(DiscourseApi::Client).to receive(:create_topic) { fail DiscourseApi::Error, '404' }
      expect(client.create_topic(title: '', raw: '')).to eq nil
    end

    it 'fails loud when different exception class than Discourse::Error is thrown' do
      allow_any_instance_of(DiscourseApi::Client).to receive(:create_topic) { fail 'Whack!' }
      expect { client.create_topic(title: '', raw: '') }.to raise_error 'Whack!'
    end
  end
end
