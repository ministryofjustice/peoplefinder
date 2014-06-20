require 'rails_helper'

RSpec.describe Department, :type => :model do
  it "should have orphaned groups as its children" do
    parent = create(:group, parent: nil)
    child = create(:group, parent: parent)
    expect(Department.instance.children.to_a).to eql([parent])
  end

  it "should call its children 'organisations'" do
    parent = create(:group, parent: nil)
    expect(Department.instance.type_of_children).to eql("Organisations")
  end
end
