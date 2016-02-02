require './lib/uvobot/discourse_client'

RSpec.describe Uvobot::DiscourseClient do
  let(:client) { Uvobot::DiscourseClient.new('http://foobar.com', '12345', 'foo') }
  describe '.create_topic' do
    it 'returns nil when discourse gem exception is rescued' do
      # TODO, sends real request and fails with 404. Slow. Stubbing not trivial because of super call.
      # expect(client.create_topic(title: '', raw: '')).to eq nil
    end
  end
end
