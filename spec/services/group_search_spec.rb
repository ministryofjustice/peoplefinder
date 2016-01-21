require 'rails_helper'

RSpec.describe GroupSearch, elastic: true do
  let!(:department) { create(:department, name: 'Department name') }
  let!(:team) { create(:group, name: 'Team name', parent: department) }
  let!(:civil_families_tribunal) { create(:group, name: 'Civil, Families & Tribunal', acronym: 'CFT', parent: department) }

  let!(:another_department) { create(:department, name: 'Another department name') }
  let!(:another_team) { create(:group, name: 'Team name', parent: another_department) }

  it 'returns empty array when query is blank' do
    expect(search('')).to eq []
  end

  it 'returns matches when query is exact match for group name' do
    results = search('Team name')
    expect(results).to include(team)
    expect(results).to include(another_team)
  end

  it 'returns matches when query is exact match for group acronym' do
    expect(search('CFT')).to eq [civil_families_tribunal]
  end

  it 'returns empty array when query is not exact match for group name' do
    expect(search('Team number one')).to eq []
  end

  it 'returns matches when all words in query are in a group name' do
    expect(search('civil')).to eq [civil_families_tribunal]
    expect(search('civil families')).to eq [civil_families_tribunal]
    expect(search('civil tribunal')).to eq [civil_families_tribunal]
  end

  def search query
    described_class.new(query).perform_search
  end

end
