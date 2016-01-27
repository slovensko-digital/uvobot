require "spec_helper"
require "./slack_notifier"

describe SlackNotifier do
  before :each do
    stub_request(:any, "https://hooks.slack.com")
  end
  let(:notifier) { SlackNotifier.new("https://hooks.slack.com") }

  describe ".new_issue_not_published" do
     it "sends correct payload to slack" do
       notifier.new_issue_not_published
       expect(WebMock).to have_requested(:post, "https://hooks.slack.com").
                            with(:body => '{"text":"*Fíha, dnes na ÚVO nevyšlo nové vydanie vestníka?*","channel":"#general","username":"uvobot","icon_emoji":":mag_right:"}')
     end
  end

  describe ".matching_announcements" do
    let(:announcements) {[
      { link: { text: "text 1", href: "href 1" }, customer: "customer 1", description: "desc 1" }
    ]}

    context "announcements found" do
      it "sends correct payloads to slack" do
        notifier.matching_announcements("Found 1 record", announcements)

        expect(WebMock).to have_requested(:post, "https://hooks.slack.com").
                             with(:body => '{"text":"Našiel som niečo nové na ÚVO! (Found 1 record)","channel":"#general","username":"uvobot","icon_emoji":":mag_right:"}')
        expect(WebMock).to have_requested(:post, "https://hooks.slack.com").
                             with(:body => '{"text":"<href 1|text 1>: *customer 1* desc 1","channel":"#general","username":"uvobot","icon_emoji":":mag_right:"}')
      end
    end

    context "announcements empty" do
      it "sends correct payloads to slack" do
        notifier.matching_announcements("", [])

        expect(WebMock).to have_requested(:post, "https://hooks.slack.com").
                             with(:body => '{"text":"Dnes som nenašiel žiadne nové IT zákazky.","channel":"#general","username":"uvobot","icon_emoji":":mag_right:"}')
      end
    end
  end
end