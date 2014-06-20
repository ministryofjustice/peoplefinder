require 'rails_helper'

RSpec.describe Group, :type => :model do
  it { should have_many(:leaders) }

  it "should return its parent if present" do
    parent = create(:group)
    child = create(:group, parent: parent)

    expect(child.parent).to eql(parent)
  end

  it "should return the Department if there is no parent" do
    orphan = create(:group, parent: nil)

    expect(orphan.parent).to eql(Department.instance)
  end

  it "should list its children" do
    parent = create(:group, parent: nil)
    child = create(:group, parent: parent)
    expect(parent.children.to_a).to eql([child])
  end

  it "should call its children 'teams'" do
    group = create(:group)
    expect(group.type_of_children).to eql("Teams")
  end
end
