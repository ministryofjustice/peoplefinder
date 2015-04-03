require 'rails_helper'

RSpec.describe Version, type: :model do
  context 'whodunnit' do
    let(:author) { create(:person) }

    it 'returns a string for the user when a string was stored' do
      subject = described_class.new(whodunnit: 'Michael Mouse')
      expect(subject.whodunnit).to eq('Michael Mouse')
    end

    it 'returns a user when their ID was stored' do
      subject = described_class.new(whodunnit: author.id.to_s)
      expect(subject.whodunnit).to eq(author)
    end

    it 'returns nil when an orphaned ID was stored' do
      subject = described_class.new(whodunnit: author.id.to_s)
      author.destroy
      expect(subject.whodunnit).to be_nil
    end
  end
end
