require 'rails_helper'

RSpec.describe PeopleHelper, type: :helper do
  describe 'day_name' do
    it "returns a name for each day" do
      expect(day_name(:works_wednesday)).to eql("Wednesday")
    end

    it "returns a symbol for each day" do
      expect(day_symbol(:works_wednesday)).to eql("W")
    end
  end

  describe 'person_form_class' do
    let(:person) { double(Person, new_record?: false) }

    it 'includes "new_person" if person is a new record' do
      allow(person).to receive(:new_record?).and_return(true)
      expect(person_form_class(person, nil)).to match(/\bnew_person\b/)
    end

    it 'includes "edit_person" if person is not a new record' do
      allow(person).to receive(:new_record?).and_return(false)
      expect(person_form_class(person, nil)).to match(/\bedit_person\b/)
    end

    it 'does not include "completing" if activity is not "complete"' do
      expect(person_form_class(person, nil)).not_to match(/\bcompleting\b/)
    end

    it 'includes "completing" if activity is "complete"' do
      expect(person_form_class(person, 'complete')).to match(/\bcompleting\b/)
    end
  end
end
