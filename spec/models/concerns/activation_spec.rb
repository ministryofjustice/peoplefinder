require 'rails_helper'

RSpec.describe Concerns::Activation do
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

  context '.activated_percentage' do

    it 'uses .completion_score_calculation for scalablility' do
      expect(Person).to receive(:completion_score_calculation).and_return(0.81)
      Person.activated_percentage
    end

    it 'returns 0 when no profiles' do
      expect(Person.activated_percentage).to eq(0)
    end

    it 'returns 0 when one person who has not logged in' do
      create(:person, login_count: 0)
      expect(Person.activated_percentage).to eq(0)
    end

    it 'returns 0 when one person who has logged in but completeness < 80%' do
      create(:person, login_count: 1)
      expect(Person.activated_percentage).to eq(0)
    end

    it 'returns 100 when one person who has logged with completeness > 80%' do
      create(:person, completed_attributes.merge(login_count: 1))
      expect(Person.activated_percentage).to eq(100)
    end

    it 'returns 50 when two people who have logged in, one with completeness > 80%, one with completeness < 80%' do
      create(:person, completed_attributes.merge(login_count: 1))
      create(:person, login_count: 1)
      expect(Person.activated_percentage).to eq(50)
    end

    it 'returns 67 when 3 people who have logged in, two with completeness > 80%, one with completeness < 80%' do
      create(:person, completed_attributes.merge(login_count: 1))
      create(:person, completed_attributes.merge(email: 'test2@digital.justice.gov.uk', login_count: 1))
      create(:person, login_count: 1)
      expect(Person.activated_percentage).to eq(67)
    end

    it 'returns 100 when two people one who has logged in with completeness > 80%, one who has not logged in' do
      create(:person, completed_attributes.merge(login_count: 1))
      create(:person, login_count: 0)
      expect(Person.activated_percentage).to eq(100)
    end

    context 'when one person created yesterday who has logged in and completion score > 80%' do
      let(:yesterday) { Date.today - 1.day }
      before do
        create(:person, completed_attributes.merge(login_count: 1, created_at: yesterday.to_time))
      end

      it 'returns 0 when from date is today' do
        expect(Person.activated_percentage(from: Date.today.to_s)).to eq(0)
      end

      it 'returns 100 when from date is yesterday' do
        expect(Person.activated_percentage(from: (yesterday - 1.hour).to_s)).to eq(100)
      end

      it 'returns 0 when before date is yesterday' do
        expect(Person.activated_percentage(before: (yesterday - 1.hour).to_s)).to eq(0)
      end

      it 'returns 100 when before date is today' do
        expect(Person.activated_percentage(before: Date.today.to_s)).to eq(100)
      end
    end
  end
end
