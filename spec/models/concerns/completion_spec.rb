require 'rails_helper'

RSpec.describe 'Completion' do # rubocop:disable RSpec/DescribeClass
  include PermittedDomainHelper

  context '#completion score' do
    it 'returns 0 if all fields are empty' do
      person = Person.new
      expect(person.completion_score).to eql(0)
      expect(person).to be_incomplete
    end

    it 'returns non-0 if a group is assigned' do
      person = Person.new(groups: [Group.new])
      expect(person.completion_score).not_to eql(0)
    end

    it 'returns 55 if half the fields are completed' do
      person = Person.new(
        given_name: generate(:given_name),
        surname: generate(:surname),
        email: generate(:email),
        city: generate(:city),
        primary_phone_number: generate(:phone_number)
      )
      expect(person.completion_score).to eql(55)
      expect(person).to be_incomplete
    end

    context 'when all the fields are completed' do
      let(:person) { Person.new(completed_attributes) }
      before { person.groups << build(:group)  }

      it 'returns 100' do
        expect(person.completion_score).to eql(100)
        expect(person).not_to be_incomplete
      end
    end
  end

  context '.overall_completion' do
    it 'returns 100 if one person is 100% complete' do
      person = create(:person, completed_attributes)
      create(:membership, person: person)
      expect(Person.overall_completion).to eq(100)
    end

    it 'returns 50 if two profiles are 50% complete' do
      2.times do
        create(:person,
          given_name: generate(:given_name),
          surname: generate(:surname),
          email: generate(:email),
          city: generate(:city),
          primary_phone_number: generate(:phone_number)
        )
      end
      expect(Person.overall_completion).to be_within(1).of(55)
    end

    it 'includes membership in calculation' do
      people = 2.times.map {
        create(:person,
          given_name: generate(:given_name),
          surname: generate(:surname),
          email: generate(:email),
          city: generate(:city),
          primary_phone_number: generate(:phone_number)
        )
      }
      2.times do
        create(:membership, person: people[0])
      end
      expect(people[0].completion_score).to eq(66)
      expect(people[1].completion_score).to eq(55)
      expect(Person.overall_completion).to be_within(1).of(61)
    end
  end

  context '.bucketed_completion' do
    it 'counts the people in each bucket' do
      people = [
        0, 18, 19,
        20, 49,
        50, 51, 52, 79,
        80, 85, 90, 99, 100
      ].map { |n| double(Person, completion_score: n) }
      allow(Person).to receive(:all).and_return(people)

      expect(Person.bucketed_completion).to eq(
        (0...20)  => 3,
        (20...50) => 2,
        (50...80) => 4,
        (80..100) => 5
      )
    end
  end

  describe '#inadequate_profiles' do
    let!(:person) { create(:person, completed_attributes) }
    subject { Person.inadequate_profiles }

    it 'is empty when all attributes are populated' do
      expect(subject).to be_empty
    end

    it 'returns the person when there is no primary phone number' do
      Person.update_all 'primary_phone_number = \'\''
      expect(subject).to include(person)
    end

    it 'returns the person when there is no location in building' do
      Person.update_all 'location_in_building = \'\''
      expect(subject).to include(person)
    end

    it 'returns the person when there is no building' do
      Person.update_all 'building = \'\''
      expect(subject).to include(person)
    end

    it 'returns the person when there is no city' do
      Person.update_all 'city = \'\''
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
      location_in_building: '13.13',
      building: '102 Petty France',
      city: 'London',
      description: 'I am a real person',
      image: Rack::Test::UploadedFile.new(sample_image)
    }
  end
end
