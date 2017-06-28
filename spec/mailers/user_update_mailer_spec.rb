require 'rails_helper'

shared_examples "observe token_auth feature flag" do
  it 'includes the token url with person show path as desired path' do
    expect(mail.body).to have_text(token_url(Token.last, desired_path: person_path(person)))
  end

  context 'token_auth feature disabled' do
    it "includes the person show url without an auth token" do
      without_feature('token_auth') do
        expect(mail.body).to have_text(person_url(person))
      end
    end
  end
end

describe UserUpdateMailer do
  include PermittedDomainHelper

  shared_examples "common #{described_class} mail elements" do
    it 'includes the email of the person who instigated the change' do
      %w(plain html).each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text(instigator.email)
      end
    end
  end

  let(:instigator) { create(:person, email: 'instigator.user@digital.justice.gov.uk') }
  let(:person) { create(:person, email: 'test.user@digital.justice.gov.uk', profile_photo_id: 1, description: 'old info') }

  describe ".new_profile_email" do
    subject(:mail) { described_class.new_profile_email(person, instigator.email).deliver_now }

    include_examples 'common mailer template elements'
    include_examples "common #{described_class} mail elements"

    it 'includes the person show url' do
      %w(plain html).each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text(person_url(person))
      end
    end
  end

  describe ".updated_profile_email" do

    let!(:hr) { create(:group, name: 'Human Resources') }
    let(:hr_membership) { create(:membership, person: person, group: hr, role: "Administrative Officer") }
    let!(:ds) { create(:group, name: 'Digital Services') }
    let!(:csg) { create(:group, name: 'Corporate Services Group') }

    let(:changes_presenter) { ProfileChangesPresenter.new(person.all_changes) }
    let(:serialized_changes) { changes_presenter.serialize }

    let(:mass_assignment_params) do
      {
        email: 'changed.user@digital.justice.gov.uk',
        works_monday: false,
        works_saturday: true,
        profile_photo_id: 2,
        description: 'changed info',
        memberships_attributes: {
          '0' => {
            role: 'Lead Developer',
            group_id: ds.id,
            leader: true,
            subscribed: false
          },
          '1' => {
            role: 'Product Manager',
            group_id: csg.id,
            leader: false,
            subscribed: true
          },
          '2' => {
            id: hr_membership.id,
            group_id: hr.id,
            role: 'Chief Executive Officer',
            leader: true,
            subscribed: false
          },
          '3' => {
            id: person.memberships.find_by(group_id: Group.department).id,
            _destroy: '1'
          }
        }
      }
    end

    let(:team_reassignment) do
      {
        memberships_attributes: {
          '2' => {
            id: hr_membership.id,
            group_id: ds.id,
            role: 'Chief Executive Officer',
            leader: true,
            subscribed: false
          }
        }
      }
    end

    subject(:mail) do
      described_class.updated_profile_email(person, serialized_changes, instigator.email).deliver_now
    end

    include_examples 'common mailer template elements'
    include_examples "common #{described_class} mail elements"

    it 'deserializes changes to create presenter objects' do
      profile_changes_presenter = double(ProfileChangesPresenter).as_null_object
      expect(ProfileChangesPresenter).to receive(:deserialize).
        with(serialized_changes).
        and_return(profile_changes_presenter)
      mail
    end

    it 'includes the person show url' do
      %w(plain html).each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text(person_url(person))
      end
    end

    context 'recipients' do
      it 'emails the changed person' do
        expect(mail.to).to include 'test.user@digital.justice.gov.uk'
        expect(mail.cc).to be_empty
      end

      it 'when email changed it emails the changed person at new address and cc\'s old address' do
        person.assign_attributes(email: 'changed.user@digital.justice.gov.uk')
        person.save!
        expect(mail.to).to include 'changed.user@digital.justice.gov.uk'
        expect(mail.cc).to include 'test.user@digital.justice.gov.uk'
      end
    end

    context 'mail content' do
      before do
        # mock controller mass assignment behaviour for applying changes
        person.assign_attributes(mass_assignment_params)
        person.save!
      end

      it 'includes team membership additions' do
        %w(plain html).each do |part_type|
          expect(get_message_part(mail, part_type)).to have_content(/Added you to the Digital Services team as Lead Developer\. You are a leader of the team/m)
          expect(get_message_part(mail, part_type)).to have_content(/Added you to the Corporate Services Group team as Product Manager/m)
        end
      end

      it 'includes team membership removals' do
        %w(plain html).each do |part_type|
          expect(get_message_part(mail, part_type)).to have_content(/Removed you from the Ministry of Justice team/m)
        end
      end

      it 'includes team membership modifications' do
        person.assign_attributes(team_reassignment)
        person.save!
        %w(plain html).each do |part_type|
          expect(get_message_part(mail, part_type)).to have_content(/Changed your membership of the Human Resources team to the Digital Services team/m)
        end
      end

      it 'includes team membership role modifications' do
        %w(plain html).each do |part_type|
          expect(get_message_part(mail, part_type)).to have_content(/Changed your role from Administrative Officer to Chief Executive Officer in the Human Resources team/m)
        end
      end

      it 'includes team membership leadership modifications' do
        %w(plain html).each do |part_type|
          expect(get_message_part(mail, part_type)).to have_content(/Made you leader of the Human Resources team/m)
        end
      end

      it 'includes team membership subscription modifications' do
        %w(plain html).each do |part_type|
          expect(get_message_part(mail, part_type)).to have_content(/Changed your notification settings so you don't get notifications if changes are made to the Human Resources team./m)
        end
      end

      it 'includes list of presented changed person attributes' do
        changes_presenter.each_pair do |_field, change|
          %w(plain html).each do |part_type|
            expect(get_message_part(mail, part_type)).to have_content(/#{change}/m)
          end
        end
      end

      it 'includes profile photo changes' do
        %w(plain html).each do |part_type|
          expect(get_message_part(mail, part_type)).to have_content(/Changed your profile photo/m)
          expect(get_message_part(mail, part_type)).to_not have_content(/Changed your profile photo id from/m)
        end
      end

      it 'includes extra info changes' do
        %w(plain html).each do |part_type|
          expect(get_message_part(mail, part_type)).to have_content(/Changed your extra information/m)
        end
      end
    end
  end

  describe ".deleted_profile_email" do
    subject(:mail) { described_class.deleted_profile_email(person.email, person.name, instigator.email).deliver_now }

    include_examples 'common mailer template elements'
    include_examples "common #{described_class} mail elements"

    it 'includes the persons name' do
      %w(plain html).each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text(person.name)
      end
    end

  end

end
