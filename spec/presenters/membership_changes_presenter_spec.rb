require 'rails_helper'

RSpec.describe MembershipChangesPresenter, type: :presenter do
  include PermittedDomainHelper

  let(:person) { create(:person) }
  let(:ds) { create(:group, name: 'Digital Services') }
  let(:csg) { create(:group, name: 'Corporate Services Group') }

  subject { described_class.new(person.changes) }

  it_behaves_like 'a changes_presenter'

  let(:mass_assignment_params) do
    {
      memberships_attributes: {
        '0' => {
          role: 'Lead Developer',
          group_id: ds.id,
          leader: true,
          subscribed: false
        },
        '1' => {
          role: 'Senior Developer',
          group_id: csg.id,
          leader: false,
          subscribed: true
        }
      }
    }
  end

  before do
    person.assign_attributes(mass_assignment_params)
    person.save!
  end

  describe '#raw' do
    subject { described_class.new(person.membership_changes).raw }

    let(:membership_changes) do
      {
        person_id: [nil, person.id],
        group_id: [nil, ds.id],
        role: [nil, "Lead Developer"],
        leader: [false, true],
        subscribed: [true, false]
      }
    end

    it 'returns all orginal changes' do
      is_expected.to be_a Hash
      expect(subject.size).to eq 2
      expect(subject.first).to include membership_changes
    end
  end

  describe '#changes' do
    subject { described_class.new(person.membership_changes).changes }

    let(:membership_changes_for_ds) do
      {
        "membership_#{ds.id}".to_sym => {
          added: {
            raw: {
              person_id: [nil, person.id],
              group_id: [nil, ds.id],
              role: [nil, "Lead Developer"],
              leader: [false, true],
              subscribed: [true, false]
            },
            message: "Added you to the Digital Services team as Lead Developer. You are a leader of the team."
          }
        }
      }
    end

    it_behaves_like '#changes on changes_presenter'

    it 'returns expected format of data' do
      is_expected.to include membership_changes_for_ds
    end

    it 'returns a set for each membership' do
      expect(subject.size).to eql 2
    end
  end

  describe '#serialize' do
    subject { described_class.new(person.membership_changes).serialize }

    include_examples 'serializability'
  end

end
