require 'rails_helper'

RSpec.describe ProfileChangesPresenter, type: :presenter do
  include PermittedDomainHelper

  let(:old_email) { 'test.user@digital.justice.gov.uk' }
  let(:new_email) { 'changed.user@digital.justice.gov.uk' }
  let!(:ds) { create(:group, name: 'Digital Services') }
  let!(:csg) { create(:group, name: 'Corporate Services Group') }
  let(:person) do
    create(
      :person,
      email: old_email,
      location_in_building: '10.51',
      description: nil
    )
  end

  let(:mass_assignment_params) do
    membership = person.reload.memberships.create(group_id: csg.id, role: "Executive Office", leader: false, subscribed: true)
    {
      given_name: "Frederick",
      surname: 'Reese-Bloggs',
      primary_phone_number: '0123 456 789',
      secondary_phone_number: '07708 139 313',
      pager_number: '0113 432 567',
      email: new_email,
      location_in_building: '',
      building: 'St Pancras',
      city: 'Manchester',
      current_project: 'Office 365 Rollout',
      works_monday: false,
      works_saturday: true,
      description: 'new info',
      profile_photo_id: 1,
      memberships_attributes: {
        '0' => {
          role: 'The Boss',
          group_id: ds.id,
          leader: true,
          subscribed: false
        },
        '1' => {
          id: membership.id,
          group_id: membership.group_id,
          role: 'Chief Executive Officer',
          leader: true,
          subscribed: false
        }
      }
    }
  end

  before do
    person.assign_attributes(mass_assignment_params)
    person.save!
  end

  subject { described_class.new(person.all_changes) }

  it_behaves_like 'a changes_presenter'

  describe '#raw' do
    subject { described_class.new(person.all_changes).raw }
    it 'returns orginal changes' do
      is_expected.to be_a Hash
      expect(subject[:email].first).to eql old_email
    end
  end

  describe '#changes' do
    subject { described_class.new(person.all_changes).changes }

    it { is_expected.to be_a Array }
    it { is_expected.to respond_to :[] }
    it { is_expected.to include instance_of PersonChangesPresenter }
    it { is_expected.to include instance_of MembershipChangesPresenter }
  end

  describe '#serialize' do
    subject { described_class.new(person.all_changes).serialize }
    include_examples 'serializability'
  end

end
