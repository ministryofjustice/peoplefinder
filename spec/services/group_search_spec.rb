require 'rails_helper'

RSpec.describe GroupSearch, elastic: true do
  let!(:department) { create(:department, name: 'Department name') }
  let!(:team) { create(:group, name: 'Team name', parent: department) }
  let!(:civil_families_tribunal) { create(:group, name: 'Civil, Families & Tribunal', acronym: 'CFT', parent: department) }
  let!(:civil_families_court) { create(:group, name: 'Civil and Families Court', acronym: 'CFT', parent: team) }

  let!(:another_department) { create(:department, name: 'Another department name') }
  let!(:another_team) { create(:group, name: 'Team name', parent: another_department) }

  describe '#perform_search' do

    it 'returns empty result set and false when query is blank' do
      expect(search('')).to eq results_struct
    end

    it 'returns exact_match as true if there is a group with exact name or acronym' do
      _results, exact_match = search('Team name')
      expect(exact_match).to eq true
    end

    it 'exact matches are case-insensitive' do
      _results, exact_match = search('team name')
      expect(exact_match).to eq true
    end

    it 'returns exact_match as false if there is NOT a group with exact name or acronym' do
      _results, exact_match = search('Team name not')
      expect(exact_match).to eq false
    end

    it 'returns matches when query is exact match for group name' do
      results = search_results('Team name')
      expect(results).to include(team)
      expect(results).to include(another_team)
    end

    it 'returns hierarchy ordered matches when query is exact match for group acronym' do
      expect(search_results('CFT')).to eq [civil_families_tribunal, civil_families_court]
    end

    it 'returns empty array when any words in query do not exist in group name' do
      expect(search_results('Team number one')).to eq []
    end

    it 'returns hierarchy ordered matches when all words in query are in a group name' do
      expect(search_results('civil')).to eq [civil_families_tribunal, civil_families_court]
      expect(search_results('civil families')).to eq [civil_families_tribunal, civil_families_court]
      expect(search_results('civil tribunal')).to eq [civil_families_tribunal]
    end
  end

  def results_struct
    [[], false]
  end

  def search_results query
    results, _exact_match = search query
    results
  end

  def search query
    described_class.new(query).perform_search
  end

end
