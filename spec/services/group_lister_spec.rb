require "rails_helper"

RSpec.describe GroupLister, type: :service do
  let!(:department) { create(:department, name: "A Department") }
  let!(:team) { create(:group, name: "A Team", parent: department) }
  let!(:subteam) { create(:group, name: "A Subteam", parent: team) }
  let!(:leaf_node) { create(:group, name: "A Leaf Node", parent: subteam) }

  context "with no maximum depth" do
    subject { described_class.new }

    let(:list) { subject.list }

    it "returns an array of group-like objects" do
      expect(list.length).to eq(4)
      expect(list.first).to be_a(described_class::ListedGroup)
    end
  end

  context "with maximum depth" do
    subject { described_class.new(2) }

    let(:list) { subject.list }

    it "returns objects only to specified depth" do
      ids = list.map(&:id).sort
      expect(ids).to eq([department.id, team.id])
    end
  end

  context "with a node with a hierarchy" do
    subject(:group_lister) { described_class.new.list.max_by(&:id) }

    it "has the name of the group" do
      expect(group_lister.name).to eq(leaf_node.name)
    end

    it "has a parent id" do
      expect(group_lister.parent_id).to eql(subteam.id)
    end

    it "has a parent" do
      expect(group_lister.parent).to be_a(described_class::ListedGroup)
      expect(group_lister.parent.id).to eq(subteam.id)
    end

    it "returns the name with path of each object" do
      expect(group_lister.name_with_path)
        .to eq("A Leaf Node [A Department > A Team > A Subteam]")
    end

    it "returns the ancestors of each node" do
      expect(group_lister.ancestors.map(&:id))
        .to eq([department.id, team.id, subteam.id])
      expect(group_lister.ancestors.first)
        .to be_a(described_class::ListedGroup)
    end

    it "returns the path of each node" do
      expect(group_lister.path.map(&:id))
        .to eq([department.id, team.id, subteam.id, leaf_node.id])
      expect(group_lister.path.first)
        .to be_a(described_class::ListedGroup)
    end
  end

  context "with a top-level node" do
    subject(:item) { described_class.new.list.min_by(&:id) }

    it "has nil parent id" do
      expect(item.parent_id).to be_nil
    end

    it "has nil parent" do
      expect(item.parent).to be_nil
    end
  end
end
