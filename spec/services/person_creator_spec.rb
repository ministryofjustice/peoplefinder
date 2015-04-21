require 'spec_helper'
require 'person_creator'

RSpec.describe PersonCreator, type: :service do
  let(:person) {
    double(
      'Person',
      save!: true,
      new_record?: false,
      notify_of_change?: false
    )
  }
  let(:current_user) { double('Current User', email: 'user@example.com') }
  subject { described_class.new(person, current_user) }

  describe 'valid?' do
    it 'delegates valid? to the person' do
      validity = double
      expect(person).to receive(:valid?).and_return(validity)
      expect(subject.valid?).to eq(validity)
    end
  end

  describe 'create!' do
    it 'saves the person' do
      expect(person).to receive(:save!)
      subject.create!
    end

    it 'sends no new profile email if not required' do
      allow(person).
        to receive(:notify_of_change?).
        with(current_user).
        and_return(false)
      expect(class_double('UserUpdateMailer').as_stubbed_const).
        to receive(:new_profile_email).
        never
      subject.create!
    end

    it 'sends a new profile email if required' do
      allow(person).
        to receive(:notify_of_change?).
        with(current_user).
        and_return(true)
      mailing = double('mailing')
      expect(class_double('UserUpdateMailer').as_stubbed_const).
        to receive(:new_profile_email).
        with(person, current_user.email).
        and_return(mailing)
      expect(mailing).to receive(:deliver_later)
      subject.create!
    end
  end
end
