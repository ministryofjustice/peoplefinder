require 'spec_helper'
require 'person_updater'

RSpec.describe PersonUpdater, type: :service do
  let(:person) {
    double(
      'Person',
      save!: true,
      send_update_email!: true,
      new_record?: false
    )
  }
  let(:current_user) { double('Current User') }
  subject { described_class.new(person, current_user) }

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

    it 'sends an update email' do
      expect(person).to receive(:send_update_email!).with(current_user)
      subject.update!
    end
  end
end
