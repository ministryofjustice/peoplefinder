require 'rails_helper'

RSpec.describe Peoplefinder::PeopleHelper, type: :helper do
  it "returns a name for each day" do
    expect(day_name(:works_wednesday)).to eql("Wednesday")
  end

  it "returns a symbol for each day" do
    expect(day_symbol(:works_wednesday)).to eql("W")
  end

  context '#contact_details' do
    it 'correctly formats complete contact details' do
      person = create(:person, email: 'hello@example.com', primary_phone_number: '0207 123 45678', secondary_phone_number: '0777-999-999')
      expect(contact_details(person)).to eql("<a href=\"mailto:hello@example.com\">hello@example.com</a><br/>0207 123 45678<br/>0777-999-999")
    end

    it 'correctly formats incomplete contact details' do
      person = create(:person, primary_phone_number: '0777-999-999')
      expect(contact_details(person)).to match(/0777-999-999/)
    end
  end
end
