require 'rails_helper'

RSpec.describe Peoplefinder::Community, type: :model do
  let(:person) { create(:person) }
  let(:community) { create(:community) }
  let(:reloaded_person) { Peoplefinder::Person.find(person.id) }

  it 'can assign a community to a person' do
    person.community = community
    person.save!

    expect(reloaded_person.community).to eq(community)
  end

  it 'can unassign a community from a person' do
    person.community = nil
    person.save!

    expect(reloaded_person.community).to be_nil
  end

  it 'prevents deletion of a community if a person is assigned to it' do
    person.community = community
    person.save

    expect { community.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)

    person.community = nil
    person.save

    community.destroy

    expect(described_class.count).to eq(0)
  end
end
