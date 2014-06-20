require 'rails_helper'

RSpec.describe GroupsHelper, :type => :helper do
  it "should call top level Department" do
    group = double(level: 0)
    expect(level_description(group)).to eql("Department")
  end

  it "should call second level Organisation" do
    group = double(level: 1)
    expect(level_description(group)).to eql("Organisation")
  end

  it "should call subsequent levels Team" do
    [3, 4, 9].each do |level|
      group = double(level: level)
      expect(level_description(group)).to eql("Team")
    end
  end

  it "should call children of top level Organisations" do
    group = double(level: 0)
    expect(child_level_description(group)).to eql("Organisations")
  end

  it "should call children of subsequent levels Teams" do
    [3, 4, 9].each do |level|
      group = double(level: level)
      expect(child_level_description(group)).to eql("Teams")
    end
  end
end
