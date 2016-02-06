RSpec.shared_examples 'notifier' do |notifier_instance|
  let(:instance) { notifier_instance }

  it 'implements matching announcements found' do
    params = instance.method(:matching_announcements_found).parameters
    expect(params.count).to eq 2
    expect(params.first).to satisfy{ |p| p == [:req, :_page] || p == [:req, :page] }
    expect(params.last).to eq [:req, :announcements]
  end

  it 'implements no announcements found' do
    expect(instance.method(:no_announcements_found).parameters).to eq []
  end

  it 'implements new issue not published' do
    expect(instance.method(:new_issue_not_published).parameters).to eq []
  end
end
