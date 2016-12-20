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
  let(:person) { create(:person, email: 'test.user@digital.justice.gov.uk') }

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

    let(:serialized_changes) { PersonChangesPresenter.new(person.changes).serialize }
    let(:serialized_membership_changes) { MembershipChangesPresenter.new(person.membership_changes).serialize }

    subject(:mail) do
      described_class.updated_profile_email(person, serialized_changes, serialized_membership_changes, instigator.email).deliver_now
    end

    before do
      person.primary_phone_number = '0123 456 789'
      person.building = ''
    end

    include_examples 'common mailer template elements'
    include_examples "common #{described_class} mail elements"

    it 'delegates .deserialize to PersonChangesPresenter' do
      changes = double('changes').as_null_object
      expect(PersonChangesPresenter).to receive(:deserialize).
        with(serialized_changes).
        and_return(changes)
      mail
    end

    it 'called with person, changes and instigator email' do
      mailing = double('mailing').as_null_object
      expect(described_class).to receive(:updated_profile_email).
        with(
          instance_of(Person),
          serialized_changes,
          serialized_membership_changes,
          an_instance_of(String)
        ).and_return(mailing)
      mail
    end

    it 'includes the person show url' do
      %w(plain html).each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text(person_url(person))
      end
    end

    context 'recipients' do
      it 'emails changed person' do
        expect(mail.to).to include 'test.user@digital.justice.gov.uk'
        expect(mail.cc).to be_empty
      end

      it 'emails changed person at new address and cc\'s old address when email changed' do
        person.email = 'changed.user@digital.justice.gov.uk'
        expect(mail.to).to include 'changed.user@digital.justice.gov.uk'
        expect(mail.cc).to include 'test.user@digital.justice.gov.uk'
      end
    end

    context 'mail content' do
      let(:changes_presenter) { PersonChangesPresenter.new(person.changes) }
      let!(:hr) { create(:group, name: 'Human Resources') }
      let!(:ds) { create(:group, name: 'Digital Services') }
      let!(:csg) { create(:group, name: 'Corporate Services Group') }

      before do
        person.memberships << build(:membership, person: person, group: hr, role: "Administrative Officer")
        person.save!
        person.works_monday = false
        person.works_saturday = true
        person.memberships << build(:membership, person: person, group: ds, role: "Lead Developer", leader: true, subscribed: false)
        person.memberships << build(:membership, person: person, group: csg, role: "Product Manager")
      end

      # TODO: removals require rewrite of form
      # TODO: changes to existing memberships require bespoke tracking method
      it 'includes team membership additions' do
        %w(plain html).each do |part_type|
          expect(get_message_part(mail, part_type)).to have_content(/Added you to the Digital Services team as Lead Developer. You are a leader of the team./m)
          expect(get_message_part(mail, part_type)).to have_content(/Added you to the Corporate Services Group team as Product Manager/m)
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
        person.profile_photo_id = 1
        person.save!
        person.profile_photo_id = 2
        %w(plain html).each do |part_type|
          expect(get_message_part(mail, part_type)).to have_content(/Changed your profile photo/m)
          expect(get_message_part(mail, part_type)).to_not have_content(/Changed your profile photo id from/m)
        end
      end

      it 'includes profile photo changes' do
        person.description = 'old info'
        person.save!
        person.description = 'new info'
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
