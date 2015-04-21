require 'spec_helper'
require 'person_destroyer'

RSpec.describe PersonDestroyer, type: :service do
  let(:person) {
    double(
      'Person',
      destroy!: true,
      new_record?: false,
      should_send_email_notification?: false
    )
  }
  let(:current_user) { double('Current User', email: 'user@example.com') }
  subject { described_class.new(person, current_user) }

  describe 'initialize' do
    it 'raises an exception if person is a new record' do
      allow(person).to receive(:new_record?).and_return(true)
      expect { subject }.to raise_error(PersonDestroyer::NewRecordError)
    end
  end

  describe 'valid?' do
    it 'delegates valid? to the person' do
      validity = double
      expect(person).to receive(:valid?).and_return(validity)
      expect(subject.valid?).to eq(validity)
    end
  end

  describe 'destroy!' do
    it 'destroys the person record' do
      expect(person).to receive(:destroy!)
      subject.destroy!
    end

    it 'sends no deleted profile email if not required' do
      allow(person).
        to receive(:should_send_email_notification?).
        with(current_user).
        and_return(false)
      expect(class_double('UserUpdateMailer').as_stubbed_const).
        to receive(:deleted_profile_email).
        never
      subject.destroy!
    end

    it 'sends a deleted profile email if required' do
      allow(person).
        to receive(:should_send_email_notification?).
        with(current_user).
        and_return(true)
      mailing = double('mailing')
      expect(class_double('UserUpdateMailer').as_stubbed_const).
        to receive(:deleted_profile_email).
        with(person, current_user.email).
        and_return(mailing)
      expect(mailing).to receive(:deliver_later)
      subject.destroy!
    end
  end
end
