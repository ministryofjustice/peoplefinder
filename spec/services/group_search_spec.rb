require 'rails_helper'

RSpec.describe GroupSearch, elastic: true do
  let!(:department) { create(:department, name: 'Department name') }
  let!(:team) { create(:group, name: 'Team name', parent: department) }
  let!(:another_department) { create(:department, name: 'Another department name') }
  let!(:team) { create(:group, name: 'Team name', parent: another_department) }

  it 'returns empty array when query is blank' do
    expect(described_class.new('').perform_search).to eq []
  end

  it 'returns matches when query is exact match for group name' do
    expect(described_class.new('Team name').perform_search).to eq [team]
  end

  it 'returns empty array when query is not exact match for group name' do
    expect(described_class.new('Team').perform_search).to eq []
  end

end
