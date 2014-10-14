require 'rails_helper'

RSpec.describe Peoplefinder::Concerns::WorkDays do

  describe '.works_weekends?' do
    let(:weekday_person) { create(:person) }
    let(:weekend_person) { create(:person,  works_saturday: true) }

    it 'returns true for a person who works only one day in the weekend' do
      expect(weekend_person.works_saturday).to eql(true)
      expect(weekend_person.works_sunday).to_not eql(true)
      expect(weekend_person.works_weekends?).to eql(true)
    end

    it 'returns true for a person who works on both a Saturday and Sunday' do
      weekend_person.update_attributes(works_sunday: true)
      expect(weekend_person.works_sunday).to eql(true)
      expect(weekend_person.works_saturday).to eql(true)
      expect(weekend_person.works_weekends?).to eql(true)
    end

    it 'returns false if neither Saturday or Sunday is worked' do
      expect(weekday_person.works_weekends?).to eql(false)
    end

  end

end
