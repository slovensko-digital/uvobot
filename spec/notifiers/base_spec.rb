require './lib/notifiers/base'

RSpec.describe Notifiers::Base do
  let(:base) { Notifiers::Base.new }

  describe '.matching_announcements_found' do
    it 'fails if not overriden' do
      expect { base.matching_announcements_found('test', 'test') }.to raise_error 'Interface method not implemented!'
    end
  end

  describe '.no_announcements_found' do
    it 'fails if not overriden' do
      expect { base.no_announcements_found }.to raise_error 'Interface method not implemented!'
    end
  end

  describe '.new_issue_not_published' do
    it 'fails if not overriden' do
      expect { base.new_issue_not_published }.to raise_error 'Interface method not implemented!'
    end
  end
end
