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
      person = Person.new(
        given_name: 'Bobby',
        surname: 'Tables',
        email: 'user.example@digital.justice.gov.uk',
        primary_phone_number: '020 7946 0123',
        secondary_phone_number: '07700 900123',
        location: 'London',
        description: 'I am a real person'
      )
      person.groups << build(:group)
      expect(person.completion_score).to eql(100)
      expect(person).not_to be_incomplete
    end
  end
end
