require 'rails_helper'

RSpec.describe PersonUpdater, type: :service do
  let(:person) do
    double(
      'Person',
      changes: { email: ['test.user@digital.justice.gov.uk', 'changed.user@digital.justice.gov.uk'] },
      save!: true,
      new_record?: false,
      notify_of_change?: false
    )
  end

  let(:current_user) { double('Current User', email: 'user@example.com') }
  subject { described_class.new(person, current_user) }

  describe 'initialize' do
    it 'raises an exception if person is a new record' do
      allow(person).to receive(:new_record?).and_return(true)
      expect { subject }.to raise_error(PersonUpdater::NewRecordError)
    end

    it 'stores changes to person as copy' do
      expect(ChangesPresenter).to receive(:new).with(person.changes)
      subject.update!
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
      changes_presenter = double('changes_presenter')
      json = double('json')
      mailing = double('mailing')

      expect(ChangesPresenter).to receive(:new).with(person.changes).and_return changes_presenter

      allow(person).
        to receive(:notify_of_change?).
        with(current_user).
        and_return(true)

      expect(changes_presenter).to receive(:serialize).and_return json

      expect(class_double('UserUpdateMailer').as_stubbed_const).
        to receive(:updated_profile_email).
        with(person, json, current_user.email).
        and_return(mailing)
      expect(mailing).to receive(:deliver_later)
      subject.update!
    end
  end
end
