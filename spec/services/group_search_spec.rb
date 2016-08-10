require 'rails_helper'

RSpec.describe GroupSearch, elastic: true do
  subject { described_class.new('', results_struct) }

  it { is_expected.to respond_to(:results) }

  let!(:department) { create(:department, name: 'Department name') }
  let!(:team) { create(:group, name: 'Team name', parent: department) }
  let!(:civil_families_tribunal) { create(:group, name: 'Civil, Families & Tribunal', acronym: 'CFT', parent: department) }
  let!(:civil_families_court) { create(:group, name: 'Civil and Families Court', acronym: 'CFT', parent: team) }

  let!(:another_department) { create(:department, name: 'Another department name') }
  let!(:another_team) { create(:group, name: 'Team name', parent: another_department) }

  describe '#perform_search' do
    # sharable with person
    #
    it 'returns instance of search results' do
      expect(search(nil)).to be_instance_of SearchResults
    end

    it 'returns empty result set and false when query is blank' do
      results = search('')
      expect(results.set).to be_empty
      expect(results.contains_exact_match).to be false
    end

    it 'calls SearchResults' do
      observer = double
      expect(observer).to receive(:set=)
      expect(observer).to receive(:contains_exact_match=)
      described_class.new('query', observer).perform_search
    end

    # group specific searches
    #
    context 'exact match flag' do
      it 'exact matches are case-insensitive' do
        results = search('team name')
        expect(exact_match).to eq true
      end

      it 'returns true if there is a group with exact name or acronym' do
        results = search('Team name')
        expect(results.contains_exact_match).to be true
      end

      it 'returns false if there is NOT a group with exact name or acronym' do
        results = search('Team name not')
        expect(results.contains_exact_match).to be false
      end
    end

    context 'results set' do
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
