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

  end
end
