require 'rails_helper'

RSpec.describe PeopleHelper, :type => :helper do
  it "should return a name for each day" do
    expect(day_name(:works_wednesday)).to eql("Wednesday")
  end

  it "should return a symbol for each day" do
    expect(day_symbol(:works_wednesday)).to eql("W")
  end

  context '#contact_details' do
    it 'should correctly format complete contact details' do
      person = create(:person, email: 'hello@example.com', phone: '0207 123 45678', mobile: '0777-999-999')
      expect(contact_details(person)).to eql("<a href=\"mailto:hello@example.com\">hello@example.com</a><br/>0207 123 45678<br/>Mob: 0777-999-999")
    end

    it 'should correctly format incomplete contact details' do
      person = create(:person, mobile: '0777-999-999')
      expect(contact_details(person)).to eql("Mob: 0777-999-999")
    end
  end

  context '#remove_membership_link' do
    it 'should return an empty string when the membership has not been saved' do
      membership = Membership.new
      expect(remove_membership_link(membership)).to be_blank
    end

    it 'should return a deletion link for an existing membership record' do
      membership = create(:membership)
      expect(remove_membership_link(membership)).to match(/<a.*>remove<\/a>/)
    end
  end
end
