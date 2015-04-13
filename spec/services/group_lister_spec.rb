require 'rails_helper'

RSpec.describe GroupLister, type: :service do
  let!(:department) { create(:department, name: 'A Department') }
  let!(:team) { create(:group, name: 'A Team', parent: department) }
  let!(:subteam) { create(:group, name: 'A Subteam', parent: team) }
  let!(:leaf_node) { create(:group, name: 'A Leaf Node', parent: subteam) }

  context 'with no maximum depth' do
    subject { described_class.new }

    let(:list) { subject.list }

    it 'returns an array of group-like objects' do
      expect(list.length).to eq(4)
      expect(list.first).to be_kind_of(described_class::ListedGroup)
    end
  end

  context 'with maximum depth' do
    subject { described_class.new(2) }

    let(:list) { subject.list }

    it 'returns objects only to specified depth' do
      ids = list.map(&:id).sort
      expect(ids).to eq([department.id, team.id])
    end
  end

  context 'a node with a hierarchy' do
    subject { described_class.new.list.sort_by(&:id).last }

    it 'has the name of the group' do
      expect(subject.name).to eq(leaf_node.name)
    end

    it 'has a parent id' do
      expect(subject.parent_id).to eql(subteam.id)
    end

    it 'has a parent' do
      expect(subject.parent).to be_kind_of(described_class::ListedGroup)
      expect(subject.parent.id).to eq(subteam.id)
    end

    it 'returns the name with path of each object' do
      expect(subject.name_with_path).
        to eq("A Leaf Node [A Department > A Team > A Subteam]")
    end

    it 'returns the ancestors of each node' do
      expect(subject.ancestors.map(&:id)).
        to eq([department.id, team.id, subteam.id])
      expect(subject.ancestors.first).
        to be_kind_of(described_class::ListedGroup)
    end

    it 'returns the path of each node' do
      expect(subject.path.map(&:id)).
        to eq([department.id, team.id, subteam.id, leaf_node.id])
      expect(subject.path.first).
        to be_kind_of(described_class::ListedGroup)
    end
  end

  context 'a top-level node' do
    subject { described_class.new.list.sort_by(&:id).first }

    it 'has nil parent id' do
      expect(subject.parent_id).to be_nil
    end

    it 'has nil parent' do
      expect(subject.parent).to be_nil
    end
  end
end
