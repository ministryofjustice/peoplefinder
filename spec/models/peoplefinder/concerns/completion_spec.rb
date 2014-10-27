require 'rails_helper'

RSpec.describe 'Completion' do # rubocop:disable RSpec/DescribeClass

  context 'completion score' do
    it 'returns 0 if all fields are empty' do
      person = Peoplefinder::Person.new
      expect(person.completion_score).to eql(0)
      expect(person).to be_incomplete
    end

    it 'returns 50 if half the fields are completed' do
      person = Peoplefinder::Person.new(
        given_name: 'Bobby',
        surname: 'Tables',
        email: 'user.example@digital.justice.gov.uk',
        primary_phone_number: '020 7946 0123'
      )
      expect(person.completion_score).to eql(50)
      expect(person).to be_incomplete
    end

    context 'when all the fields are completed' do
      let(:person) { Peoplefinder::Person.new(completed_attributes) }
      before { person.groups << build(:group)  }

      it 'returns 100' do
        expect(person.completion_score).to eql(100)
        expect(person).not_to be_incomplete
      end

      context 'and no_phone = true' do
        it 'returns 100 even if the primary_phone_number is blank' do
          person.no_phone = true
          person.primary_phone_number = nil
          expect(person.completion_score).to eql(100)
        end
      end
    end
  end

  describe '#inadequate_profiles' do
    let!(:person) { create(:person, completed_attributes) }
    subject { Peoplefinder::Person.inadequate_profiles }

    it 'is empty when all attributes are populated' do
      expect(subject).to be_empty
    end

    it 'returns the person when there is no primary phone number' do
      Peoplefinder::Person.update_all 'primary_phone_number = \'\''
      expect(subject).to include(person)
    end

    context 'with no_phone = true' do
      it 'does not return the person even if there is no primary_phone_number' do
        Peoplefinder::Person.update_all 'primary_phone_number = null, no_phone = true'
        expect(subject).not_to include(person)
      end
    end

    it 'returns the person when there is no location' do
      Peoplefinder::Person.update_all 'location = \'\''
      expect(subject).to include(person)
    end

    it 'returns the person when there is no image' do
      Peoplefinder::Person.update_all 'image = null'
      expect(subject).to include(person)
    end
  end

  def completed_attributes
    {
      given_name: 'Bobby',
      surname: 'Tables',
      email: 'user.example@digital.justice.gov.uk',
      primary_phone_number: '020 7946 0123',
      location: 'London',
      description: 'I am a real person',
      image: Rack::Test::UploadedFile.new(sample_image)
    }
  end
end
