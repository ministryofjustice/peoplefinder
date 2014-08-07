require 'rails_helper'

RSpec.describe GroupHierarchy, :type => :model do
  it "should generate a tree of hashes with group information" do
    root =
      create(:group, name: 'A', slug: 'a', children: [
        create(:group, name: 'B', slug: 'b', children: [
          create(:group, name: 'C', slug: 'c', children: []),
          create(:group, name: 'D', slug: 'd', children: [])
        ]),
        create(:group, name: 'E', slug: 'e', children: [])
      ])

    root.reload

    expected = {
      name: 'A',
      url: '/groups/a',
      children: [
        {
          name: 'B',
          url: '/groups/b',
          children: [
            {
              name: 'C',
              url: '/groups/c',
              children: []
            }, {
              name: 'D',
              url: '/groups/d',
              children: []
            },
          ]
        }, {
          name: 'E',
          url: '/groups/e',
          children: []
        }
      ]
    }

    generated = GroupHierarchy.new(root).to_hash

    expect(generated).to eql(expected)
  end
end
