# == Schema Information
#
# Table name: versions
#
#  id             :integer          not null, primary key
#  item_type      :text             not null
#  item_id        :integer          not null
#  event          :text             not null
#  whodunnit      :text
#  object         :text
#  created_at     :datetime
#  object_changes :text
#  ip_address     :string
#  user_agent     :string
#

require 'rails_helper'

RSpec.describe Version, type: :model do
  include PermittedDomainHelper

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
