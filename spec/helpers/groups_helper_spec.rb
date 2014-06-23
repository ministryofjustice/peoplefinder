require 'rails_helper'

RSpec.describe GroupsHelper, :type => :helper do
  it "should list second level Organisations" do
    dept = double(level: 0)
    expect(child_group_list_title(dept)).to eql("Organisations")
  end

  it "should list subsequent level Teams" do
    [3, 4, 9].each do |level|
      group = double(level: level)
      expect(child_group_list_title(group)).to eql("Teams")
    end
  end

  it "should use 'Add organisation' as CTA from department" do
    dept = double(level: 0)
    expect(new_child_group_cta(dept)).to eql("Add organisation")
  end

  it "should use 'Add team' as CTA from organisation" do
    [3, 4, 9].each do |level|
      group = double(level: level)
      expect(new_child_group_cta(group)).to eql("Add team")
    end
  end
end
