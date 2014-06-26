require 'rails_helper'

RSpec.describe PeopleHelper, :type => :helper do
  it "should return a name for each day" do
    expect(day_name(:works_wednesday)).to eql("Wednesday")
  end

  it "should return a symbol for each day" do
    expect(day_symbol(:works_wednesday)).to eql("W")
  end
end
