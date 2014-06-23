require 'rails_helper'

RSpec.describe Group, :type => :model do
  it { should have_one(:leader) }

  it "should list orphaned groups as departments" do
    parent = create(:group, parent: nil)
    child = create(:group, parent: parent)
    expect(Group.departments.to_a).to eql([parent])
  end

  it "should calculate its level" do
    parent = Group.new
    child = Group.new(parent: parent)
    expect(parent.level).to eql(0)
    expect(child.level).to eql(1)
  end
end
