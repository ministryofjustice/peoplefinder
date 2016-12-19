require 'rails_helper'

RSpec.describe MembershipChangesPresenter, type: :presenter do
  include PermittedDomainHelper

  let(:person) do
    create(:person)
  end

  let(:ds) do
    create(:group, name: 'Digital Services')
  end
  let(:csg) do
    create(:group, name: 'Corporate Services Group')
  end

  subject { described_class.new(person.changes) }

  it { is_expected.to be_a(described_class) }
  it { is_expected.to respond_to :changes }
  it { is_expected.to respond_to :raw }
  it { is_expected.to respond_to :[] }
  it { is_expected.to respond_to :each }
  it { is_expected.to respond_to :each_pair }

  describe '#raw' do
    subject { described_class.new(person.membership_changes).raw }
    before do
      person.email = 'test.user@digital.justice.gov.uk'
      person.memberships << build(:membership, person: person, group: ds, role: "Lead Developer")
      person.memberships << build(:membership, person: person, group: csg, role: "Senior Developer")
    end

    let(:membership_changes) do
      {
        person_id: [nil, person.id],
        group_id: [nil, ds.id],
        role: [nil, "Lead Developer"]
      }
    end

    it 'returns all orginal changes' do
      is_expected.to be_a Hash
      expect(subject.size).to eq 2
      expect(subject.first).to include membership_changes
    end
  end

end
