require 'rails_helper'

RSpec.describe PersonUpdater, type: :service do
  let(:person) do
    double(
      'Person',
      all_changes: { email: ['test.user@digital.justice.gov.uk', 'changed.user@digital.justice.gov.uk'], membership_12: { group_id: [1, nil] } },
      save!: true,
      new_record?: false,
      notify_of_change?: false
    )
  end

  let(:null_object) { double('null_object').as_null_object }
  let(:current_user) { double('Current User', email: 'user@example.com') }

  subject { described_class.new(person: person, current_user: current_user, state_cookie: smc) }

  context 'Saving profile on update' do

    let(:smc) { double StateManagerCookie, save_profile?: true, create?: false }

    before do
      allow(Group).to receive(:find).and_return null_object
    end

    describe 'initialize' do
      it 'raises an exception if person is a new record' do
        allow(person).to receive(:new_record?).and_return(true)
        expect { subject }.to raise_error(PersonUpdater::NewRecordError)
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

      it 'stores changes to person for use in update email' do
        expect(person).to receive(:notify_of_change?).and_return(true)
        expect(QueuedNotification).to receive(:queue!).with(subject)
        subject.update!
      end

      it 'sends no update email if not required' do
        allow(person).
          to receive(:notify_of_change?).
          with(current_user).
          and_return(false)
        expect(QueuedNotification).not_to receive(:queue!)
        subject.update!
      end

      it 'sends creates a queued notification if required' do
        allow(person).
          to receive(:notify_of_change?).
          with(current_user).
          and_return(true)

        expect(QueuedNotification).to receive(:queue!)
        subject.update!
      end
    end
  end

  context 'saving profile on create' do
    let(:smc) { double StateManagerCookie, save_profile?: true, create?: true }

    it 'queues a update notification' do
      allow(person).to receive(:notify_of_change?).and_return(true)
      expect(QueuedNotification).to receive(:queue!)
      subject.update!
    end

  end

end
