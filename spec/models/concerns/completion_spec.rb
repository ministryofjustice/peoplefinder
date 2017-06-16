require 'rails_helper'

RSpec.describe 'Completion' do # rubocop:disable RSpec/DescribeClass
  include PermittedDomainHelper

  let(:completed_attributes) do
    {
      given_name: 'Bobby',
      surname: 'Tables',
      email: 'user.example@digital.justice.gov.uk',
      primary_phone_number: '020 7946 0123',
      location_in_building: '13.13',
      building: '102 Petty France',
      city: 'London',
      description: 'I am a real person',
      profile_photo_id: profile_photo.id
    }
  end

  let(:profile_photo) do
    create(:profile_photo)
  end

  let(:person) do
    create(:person)
  end

  context '#completion_score' do
    it 'returns 0 if all fields are empty' do
      person = Person.new
      expect(person.completion_score).to eql(0)
      expect(person).to be_incomplete
    end

    it 'returns non-zero for any persisted person' do
      expect(person.completion_score).not_to eq 0
    end

    it 'returns higher score if a group is assigned' do
      person.memberships.destroy_all
      initial = person.completion_score
      create(:membership, person: person)
      expect(person.completion_score).to be > initial
    end

    it 'returns 55 if half the fields are completed' do
      person = create(:person, city: generate(:city), primary_phone_number: generate(:phone_number))
      person.memberships.destroy_all
      expect(person.completion_score).to be_within(1).of(55)
      expect(person).to be_incomplete
    end

    context 'when all the fields are completed' do
      let(:person) { create(:person, completed_attributes) }
      before { create(:membership, person: person) }

      it 'returns 100' do
        expect(person.completion_score).to eql(100)
        expect(person).not_to be_incomplete
      end
    end

    context 'when legacy image field exists instead of profile photo and all other fields completed' do
      let(:person) do
        create(
          :person,
          completed_attributes.
            reject { |k, _v| k == :profile_photo_id }.
            merge(image: 'profile_MoJ_small.jpg')
        )
      end
      before { create(:membership, person: person) }

      it 'returns 100' do
        expect(person.completion_score).to eql(100)
        expect(person).not_to be_incomplete
      end
    end
  end

  context '.overall_completion' do
    it 'calls method encapsulating contruction of raw SQL for average completion score' do
      expect(Person).to receive(:average_completion_score)
      Person.overall_completion
    end

    it 'returns 100 if there is only one person who is 100% complete' do
      person = create(:person, completed_attributes)
      create(:membership, person: person)
      expect(Person.overall_completion).to eq(100)
    end

    it 'returns average of two profiles completion scores' do
      2.times do
        person = create(
          :person,
          given_name: generate(:given_name),
          surname: generate(:surname),
          email: generate(:email),
          city: generate(:city),
          primary_phone_number: generate(:phone_number)
        )
      end
      expect(Person.overall_completion).to be_within(1).of(67)
    end

    it 'includes membership in calculation' do
      people = 2.times.map do
        person = create(
          :person,
          given_name: generate(:given_name),
          surname: generate(:surname),
          email: generate(:email),
          city: generate(:city),
          primary_phone_number: generate(:phone_number)
        )
        person.memberships.destroy_all
        person
      end
      expect(UpdateGroupMembersCompletionScoreJob).to receive(:perform_later).at_least(:once)
      2.times do
        create(:membership, person: people[0])
      end
      people.each(&:reload)
      expect(people[0].completion_score).to be_within(1).of(66)
      expect(people[1].completion_score).to be_within(1).of(55)
      expect(Person.overall_completion).to be_within(1).of(61)
    end
  end

  context '.completion_score_calculation' do
    it 'constructs sql to calculate score based on existence of values for important fields' do
      sql_regex = /COALESCE.*CASE WHEN length\(.*\,0\)\)::float.*/mi
      expect(Person.completion_score_calculation).to match(sql_regex)
    end

    it 'uses number of COMPLETION_FIELDS to calculate fraction part of the whole' do
      expect(Person::COMPLETION_FIELDS).to receive(:size)
      Person.completion_score_calculation
    end
  end

  context '.average_completion_score' do
    it 'executes raw SQL for scalability/performance' do
      conn = double.as_null_object
      expect(ActiveRecord::Base).to receive(:connection).at_least(:once).and_return(conn)
      expect(conn).to receive(:execute).with(/^\s*SELECT AVG\(.*$/i)
      Person.average_completion_score
    end

    it 'returns a rounded float for use as a percentage' do
      create(:person, :with_details)
      expect(Person.average_completion_score).to eql 89
    end
  end

  describe '.inadequate_profiles' do
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
      Person.update_all 'profile_photo_id = null'
      expect(subject).to include(person)
    end
  end
end
