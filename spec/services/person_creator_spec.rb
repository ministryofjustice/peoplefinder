require 'spec_helper'
require 'person_creator'

RSpec.describe PersonCreator, type: :service do
  let(:person) { double('Person', save!: true, send_create_email!: true) }
  let(:current_user) { double('Current User') }
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

    it 'sends a creation email' do
      expect(person).to receive(:send_create_email!).with(current_user)
      subject.create!
    end
  end
end
