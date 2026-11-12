require './lib/uvobot/uvo_scraper'
require './lib/uvobot/worker'
require './lib/uvobot/notifications/discourse_notifier'
require 'date'

RSpec.describe 'current UVO notice workflow' do
  let(:http_client) { double('HTTP client') }
  let(:discourse_client) { double('Discourse client') }
  let(:scraper) { Uvobot::UvoScraper.new(Uvobot::UvoParser, http_client) }
  let(:notifier) { Uvobot::Notifications::DiscourseNotifier.new(discourse_client, 'it', scraper) }
  let(:worker) { Uvobot::Worker.new(scraper, [notifier]) }

  before do
    allow(http_client).to receive(:get).with(
      'https://www.uvo.gov.sk/vestnik-a-registre/vestnik?date=11.11.2026', verify: false, timeout: 30
    ).and_return(double(code: 200, body: '<h1>Vestník č. 229/2026 - 11.11.2026</h1>'))
  end

  it 'builds a forum topic from current list and eForms detail HTML' do
    allow(http_client).to receive(:get).with(
      start_with(Uvobot::UvoScraper::SEARCH_URL + '?'), verify: false, timeout: 30
    ).and_return(double(code: 200, body: File.read('./spec/support/fixtures/current_announcements.html')))
    detail_url = 'https://www.uvo.gov.sk/vestnik-a-registre/vestnik/oznamenie/detail/1424997?cHash=43c748aa0ed07ab9eb579fb6a62d02cd'
    allow(http_client).to receive(:get).with(detail_url, verify: false, timeout: 30)
      .and_return(double(code: 200, body: File.read('./spec/support/fixtures/eforms_result_announcement_detail.html')))

    expect(discourse_client).to receive(:create_topic).with(
      title: 'Obnova a rozšírenie nástroja na monitoring zraniteľnosti IP adresného priestoru a správu',
      category: 'it',
      raw: "**Obstarávateľ:** Národná diaľničná spoločnosť, a.s.  \n" \
           "**Predmet obstarávania:** Obnova a rozšírenie nástroja na monitoring zraniteľnosti IP adresného priestoru a správu  \n" \
           "**Typ oznamu:** Oznámenie o výsledku verejného obstarávania  \n" \
           "**Cena:** 832 032 Euro  \n**Druh postupu:** Verejná súťaž  \n" \
           "**Víťaz obstarávania:**  \n NovalogiX s. r. o.  \n**Zdroj:** [16081 - VSS](#{detail_url})"
    )

    worker.run(Date.new(2026, 11, 11))
  end

  it 'does not send a misleading no-results notification when access fails' do
    allow(http_client).to receive(:get).with(
      start_with(Uvobot::UvoScraper::SEARCH_URL + '?'), verify: false, timeout: 30
    ).and_return(double(code: 403, body: 'Forbidden'))
    expect(notifier).not_to receive(:no_announcements_found)
    expect(discourse_client).not_to receive(:create_topic)

    expect { worker.run(Date.new(2026, 11, 11)) }.to raise_error(Uvobot::UvoScraper::RequestFailed, /HTTP 403/)
  end
end
