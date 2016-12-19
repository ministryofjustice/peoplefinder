require 'rails_helper'

RSpec.describe PersonUpdater, type: :service do
  let(:person) do
    double(
      'Person',
      changes: { email: ['test.user@digital.justice.gov.uk', 'changed.user@digital.justice.gov.uk'] },
      membership_changes: { membership_7771: { group_id: [1, nil] } },
      save!: true,
      new_record?: false,
      notify_of_change?: false
    )
  end

  let(:null_object) { double('null_object').as_null_object }
  let(:current_user) { double('Current User', email: 'user@example.com') }
  subject { described_class.new(person, current_user) }

  before do
    allow(Group).to receive(:find).and_return null_object
  end

  describe 'initialize' do
    it 'raises an exception if person is a new record' do
      allow(person).to receive(:new_record?).and_return(true)
      expect { subject }.to raise_error(PersonUpdater::NewRecordError)
    end

    it 'stores changes to person for use in update email' do
      expect(person).to receive(:changes)
      expect(person).to receive(:membership_changes)
      subject
    end
  end

  describe 'valid?' do
    it 'delegates valid? to the person' do
      validity = double
      expect(person).to receive(:valid?).and_return(validity)
      expect(subject.valid?).to eq(validity)
    end
  end

  describe 'update!' do
    it 'saves the person' do
      expect(person).to receive(:save!)
      subject.update!
    end

    it 'sends no update email if not required' do
      allow(person).
        to receive(:notify_of_change?).
        with(current_user).
        and_return(false)
      expect(class_double('UserUpdateMailer').as_stubbed_const).
        to receive(:updated_profile_email).
        never
      subject.update!
    end

    it 'sends an update email if required' do
      person_changes_presenter = double('person_changes_presenter')
      membership_changes_presenter = double('membership_changes_presenter')
      json = double('json')
      mailing = double('mailing')

      expect(PersonChangesPresenter).to receive(:new).with(person.changes).and_return person_changes_presenter
      expect(MembershipChangesPresenter).to receive(:new).with(person.membership_changes).and_return membership_changes_presenter

      allow(person).
        to receive(:notify_of_change?).
        with(current_user).
        and_return(true)

      expect(person_changes_presenter).to receive(:serialize).and_return json
      expect(membership_changes_presenter).to receive(:serialize).and_return json

      expect(class_double('UserUpdateMailer').as_stubbed_const).
        to receive(:updated_profile_email).
        with(person, json, json, current_user.email).
        and_return(mailing)
      expect(mailing).to receive(:deliver_later)
      subject.update!
    end
  end
end
