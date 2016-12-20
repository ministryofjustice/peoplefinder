require 'rails_helper'

RSpec.describe MembershipChangesPresenter, type: :presenter do
  include PermittedDomainHelper

  let(:person) { create(:person) }
  let(:ds) { create(:group, name: 'Digital Services') }
  let(:csg) { create(:group, name: 'Corporate Services Group') }

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

  describe '#changes' do
    before do
      membership_for_ds
      person.memberships << build(:membership, person: person, group: csg, role: "Senior Developer")
    end

    let(:membership_for_ds) do
      membership = build(:membership, person: person, group: ds, role: "Lead Developer", leader: true, subscribed: false)
      person.memberships << membership
      membership
    end

    subject { described_class.new(person.membership_changes).changes }

    let(:membership_changes_for_ds) do
      {
        "membership_#{membership_for_ds.object_id}".to_sym => {
          added: {
            raw: {
              person_id: [
                nil,
                person.id
              ],
              group_id: [
                nil,
                membership_for_ds.group_id
              ],
              role: [
                nil,
                "Lead Developer"
              ],
              leader: [
                false,
                true
              ],
              subscribed: [
                true,
                false
              ]
            },
            message: "Added you to the Digital Services team as Lead Developer. You are a leader of the team."
          }
        }
      }
    end

    it { is_expected.to be_a Hash }
    it { is_expected.to respond_to :[] }
    it { is_expected.to respond_to :each }
    it { is_expected.to respond_to :each_pair }

    it 'returns expected format of data' do
      is_expected.to include membership_changes_for_ds
    end

    it 'returns a set for each membership' do
      expect(subject.size).to eql 2
    end
  end
end
