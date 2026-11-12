require './lib/uvobot/uvo_parser'

RSpec.describe 'eForms announcement details' do
  let(:result_html) { File.read('./spec/support/fixtures/eforms_result_announcement_detail.html') }
  let(:procurement_html) { File.read('./spec/support/fixtures/eforms_procurement_announcement_detail.html') }

  it 'extracts the awarded total and winner, not the estimated price or the buyer' do
    expect(Uvobot::UvoParser.parse_detail(result_html)).to eq(
      announcement_type: 'Oznámenie o výsledku verejného obstarávania',
      amount: '832 032 Euro',
      procurement_type: 'Verejná súťaž',
      procurement_winner: 'NovalogiX s. r. o.'
    )
  end

  it 'extracts estimated value, duration and submission deadline for a competition' do
    expect(Uvobot::UvoParser.parse_detail(procurement_html)).to eq(
      announcement_type: 'Oznámenie o vyhlásení verejného obstarávania',
      amount: '847 166 Euro',
      procurement_type: 'Verejná súťaž',
      project_runtime: '34 Mesiac',
      proposal_placing_term: '22.09.2026 15:30'
    )
  end

  it 'does not substitute an estimate when the awarded total is missing' do
    html = result_html.gsub(/<li>Celková hodnota oznámenia[^<]*<\/li>/, '')
    expect(Uvobot::UvoParser.parse_detail(html).fetch(:amount)).to be_nil
  end

  it 'does not call every bidder a winner when the references are ambiguous' do
    html = result_html.sub('ID uchádzača: ORG-0003', 'ID uchádzača: ORG-0004 (Other supplier)</li><li>ID uchádzača: ORG-0003')
    expect(Uvobot::UvoParser.parse_detail(html).fetch(:procurement_winner)).to be_nil
  end

  it 'does not infer a winner without a successful offer' do
    html = result_html.sub('<li>Identifikátor úspešnej ponuky: TEN-0001</li>', '')
    expect(Uvobot::UvoParser.parse_detail(html).fetch(:procurement_winner)).to be_nil
  end

  it 'does not invent a winner when no winner was selected' do
    html = result_html.sub('Bol vybratý aspoň jeden víťaz', 'Nebol vybratý žiadny víťaz')
    expect(Uvobot::UvoParser.parse_detail(html).fetch(:procurement_winner)).to be_nil
  end

  it 'does not pick an arbitrary duration or deadline from different lots' do
    extra_lot = '<li>Dĺžka trvania (BT-36-Lot) (hodnota): 12</li>' \
                '<li>Lehota na predkladanie ponúk (dátum): 23.09.2026</li>'
    html = procurement_html.sub('</ul>', "#{extra_lot}</ul>")
    expect(Uvobot::UvoParser.parse_detail(html)).to include(project_runtime: nil, proposal_placing_term: nil)
  end

  it 'handles missing optional fields without failing' do
    html = '<div id="output-container"><h3 class="title">Oznámenie</h3><ul><li>Typ formulára: Súťaž</li></ul></div>'
    expect(Uvobot::UvoParser.parse_detail(html)).to include(
      announcement_type: 'Oznámenie', amount: nil, project_runtime: nil, proposal_placing_term: nil
    )
  end
end
