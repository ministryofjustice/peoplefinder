require 'rails_helper'

RSpec.describe 'Completion' do # rubocop:disable RSpec/DescribeClass

  context 'completion score' do
    it 'returns 0 if all fields are empty' do
      person = Person.new
      expect(person.completion_score).to eql(0)
      expect(person).to be_incomplete
    end

    it 'returns 50 if half the fields are filled' do
      person = Person.new(
        given_name: 'Bobby',
        surname: 'Tables',
        email: 'user.example@digital.justice.gov.uk',
        primary_phone_number: '020 7946 0123'
      )
      expect(person.completion_score).to eql(50)
      expect(person).to be_incomplete
    end

    it 'returns 100 if all fields are filled' do
      person = Person.new(completed_attributes)
      person.groups << build(:group)
      expect(person.completion_score).to eql(100)
      expect(person).not_to be_incomplete
    end
  end

  describe '#inadequate_profiles' do
    let!(:person) { create(:person, completed_attributes) }
    subject { Person.inadequate_profiles }

    it 'is empty when all attributes are populated' do
      expect(subject).to be_empty
    end

    it 'returns the person when there is neither phone nor secondary number' do
      Person.update_all 'primary_phone_number = \'\', secondary_phone_number = null'
      expect(subject).to include(person)
    end

    it 'returns the person when there is no location' do
      Person.update_all 'location = \'\''
      expect(subject).to include(person)
    end

    it 'returns the person when there is no image' do
      Person.update_all 'image = null'
      expect(subject).to include(person)
    end
  end

  def completed_attributes
    {
      given_name: 'Bobby',
      surname: 'Tables',
      email: 'user.example@digital.justice.gov.uk',
      primary_phone_number: '020 7946 0123',
      secondary_phone_number: '07700 900123',
      location: 'London',
      description: 'I am a real person',
      image: Rack::Test::UploadedFile.new(sample_image)
    }
  end
end
