require 'rails_helper'

RSpec.describe PeopleHelper, :type => :helper do
  it "should return a name for each day" do
    expect(day_name(:works_wednesday)).to eql("Wednesday")
  end

  it "should return a symbol for each day" do
    expect(day_symbol(:works_wednesday)).to eql("W")
  end

  it 'should return group breadcrumbs' do
    justice = create(:group, name: 'Justice')
    digital_service = create(:group, parent: justice, name: 'Digital Services')
    expect(group_breadcrumbs(digital_service)).to eql("<a href=\"/groups/justice\">Justice</a> > <a href=\"/groups/digital-services\">Digital Services</a>")
  end
end
