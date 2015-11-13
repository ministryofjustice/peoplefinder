require 'rails_helper'

RSpec.describe 'Acquisition' do
  include PermittedDomainHelper

  context '.acquired_percentage' do
    it 'returns 0 when no profiles' do
      expect(Person.acquired_percentage).to eq(0)
    end

    it 'returns 0 when one person who has not logged in' do
      create(:person, login_count: 0)
      expect(Person.acquired_percentage).to eq(0)
    end

    it 'returns 100 when one person who has logged in' do
      create(:person, login_count: 1)
      expect(Person.acquired_percentage).to eq(100)
    end

    it 'returns 50 if two people, one who has logged in, one who has not' do
      create(:person, login_count: 1)
      create(:person, login_count: 0)
      expect(Person.acquired_percentage).to eq(50)
    end

    it 'returns 67 when 3 people, two who have logged in, one who has not' do
      create(:person, login_count: 1)
      create(:person, login_count: 1)
      create(:person, login_count: 0)
      expect(Person.acquired_percentage).to eq(67)
    end

    context 'when one person created yesterday who has logged in' do
      before do
        create(:person, login_count: 1, created_at: Date.yesterday.to_time)
      end

      it 'returns 0 when from date is today' do
        expect(Person.acquired_percentage(from: Date.today.to_s)).to eq(0)
      end

      it 'returns 100 when from date is yesterday' do
        expect(Person.acquired_percentage(from: Date.yesterday.to_s)).to eq(100)
      end

      it 'returns 0 when before date is yesterday' do
        expect(Person.acquired_percentage(before: Date.yesterday.to_s)).to eq(0)
      end

      it 'returns 100 when before date is today' do
        expect(Person.acquired_percentage(before: Date.today.to_s)).to eq(100)
      end
    end
  end
end
