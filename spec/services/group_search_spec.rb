require 'rails_helper'
require_relative 'shared_examples_for_search'

RSpec.describe GroupSearch, elastic: true do
  let!(:department) { create(:department, name: 'Department name') }
  let!(:team) { create(:group, name: 'Team name', parent: department) }
  let!(:civil_families_tribunal) { create(:group, name: 'Civil, Families & Tribunal', acronym: 'CFT', parent: department) }
  let!(:civil_families_court) { create(:group, name: 'Civil and Families Court', acronym: 'CFT', parent: team) }
  let!(:another_department) { create(:department, name: 'Another department name') }
  let!(:another_team) { create(:group, name: 'Team name', parent: another_department) }

  describe '#perform_search' do
    it_behaves_like 'a search'

    context 'exact match flag' do
      it 'is case-insensitive' do
        results = search('team name')
        expect(results.contains_exact_match).to eq true
      end

      it 'true if there is a group with exact name or acronym' do
        results = search('Team name')
        expect(results.contains_exact_match).to be true
      end

      it 'false if there is NOT a group with exact name or acronym' do
        results = search('Team name not')
        expect(results.contains_exact_match).to be false
      end
    end

    context 'result set' do
      it 'returns matches when query is exact match for group name' do
        set = result_set('Team name')
        expect(set).to include(team)
        expect(set).to include(another_team)
      end

      it 'returns hierarchy ordered matches when query is exact match for group acronym' do
        expect(result_set('CFT')).to eq [civil_families_tribunal, civil_families_court]
      end

      it 'returns empty array when any words in query do not exist in group name' do
        expect(result_set('Team number one')).to eq []
      end

      it 'returns hierarchy ordered matches when all words in query are in a group name' do
        expect(result_set('civil')).to eq [civil_families_tribunal, civil_families_court]
        expect(result_set('civil families')).to eq [civil_families_tribunal, civil_families_court]
        expect(result_set('civil tribunal')).to eq [civil_families_tribunal]
      end

      it 'ignores non-word characters' do
        expect { result_set('*') }.not_to raise_error
        expect(result_set('\Team/name?')).to match_array([team, another_team])
      end

    end
  end

  def results_struct
    SearchResults.new
  end

  def result_set query
    results = search query
    results.set
  end

  def search query
    described_class.new(query, results_struct).perform_search
  end

end
