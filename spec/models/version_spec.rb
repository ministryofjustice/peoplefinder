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

  context '#whodunnit' do
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

  describe '#reify' do

    before do
      with_versioning do
        person = create(:person, surname: 'Necro')
        person.destroy
      end
    end

    let(:version) { described_class.where(item_type: 'Person').last }

    it 'returns instance of reified object' do
      expect(version.reify).to be_instance_of Person
    end

    it 'skips must_have_team validation on person' do
      expect_any_instance_of(Person).to receive(:skip_must_have_team=).with(true)
      version.reify
    end
  end
end
