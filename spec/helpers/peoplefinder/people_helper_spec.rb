require 'rails_helper'

RSpec.describe Peoplefinder::PeopleHelper, type: :helper do
  it "returns a name for each day" do
    expect(day_name(:works_wednesday)).to eql("Wednesday")
  end

  it "returns a symbol for each day" do
    expect(day_symbol(:works_wednesday)).to eql("W")
  end
end
