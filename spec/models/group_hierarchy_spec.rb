require 'rails_helper'

RSpec.describe GroupHierarchy, type: :model do
  it "generates a tree of hashes with group information" do
    a, b, c, d, e = create_hierarchy_of_groups
    a.reload

    expected = {
      id: a.id,
      name: 'A',
      url: "/groups/#{ a.id }",
      children: [
        {
          id: b.id,
          name: 'B',
          url: "/groups/#{ b.id }",
          children: [
            {
              id: c.id,
              name: 'C',
              url: "/groups/#{ c.id }",
              children: []
            }, {
              id: d.id,
              name: 'D',
              url: "/groups/#{ d.id }",
              children: []
            }
          ]
        }, {
          id: e.id,
          name: 'E',
          url: "/groups/#{ e.id }",
          children: []
        }
      ]
    }

    generated = described_class.new(a).to_hash

    expect(generated).to eql(expected)
  end

  context 'Generating a group_id list' do
    let(:root) { create_hierarchy_of_groups.first }
    subject { described_class.new(root).to_group_id_list }

    it 'has five elements' do
      expect(subject.length).to eql(5)
    end

    it 'includes each of the five groups' do
      %w[ A B C D E ].each do |name|
        expect(subject).to include(Group.find_by_name(name).id)
      end
    end
  end

  def create_hierarchy_of_groups
    a = create(:group, name: 'A')
    b = create(:group, name: 'B', parent: a)
    c = create(:group, name: 'C', parent: b)
    d = create(:group, name: 'D', parent: b)
    e = create(:group, name: 'E', parent: a)
    [a, b, c, d, e]
  end
end
