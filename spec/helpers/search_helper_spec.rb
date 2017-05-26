require 'rails_helper'

RSpec.describe SearchHelper, type: :helper do
  subject { helper }

  before do
    @people_results = SearchResults.new
    @team_results = SearchResults.new
  end

  it { is_expected.to respond_to :people_count }
  it { is_expected.to respond_to :team_count }
  it { is_expected.to respond_to :result_count }
  it { is_expected.to respond_to :result_summary }

  describe '#people_count' do
    it 'returns 0 or more' do
      expect(helper.people_count).to eql 0
    end

    it 'returns people results instance variable\'s size' do
      expect(@people_results).to receive(:set).and_return %w(person1 person2)
      expect(helper.people_count).to eql 2
    end
  end

  describe '#team_count' do
    it 'returns 0 or more' do
      expect(helper.team_count).to eql 0
    end

    it 'returns team results instance variable\'s size' do
      expect(@team_results).to receive(:set).and_return %w(team1 team2 team3)
      expect(helper.team_count).to eql 3
    end
  end

  describe '#result_count' do
    it 'returns 0 or more' do
      expect(helper.result_count).to eql 0
    end

    it 'delegates to people and team result set sizes' do
      expect(helper).to receive(:people_count).and_return 4
      expect(helper).to receive(:team_count).and_return 1
      expect(helper.result_count).to eq 5
    end
  end

  describe '#result_summary' do
    before do
      @search_filters = %w(people teams)
      allow(helper).to receive(:people_count).and_return 3
      allow(helper).to receive(:team_count).and_return 1
    end

    context 'when matches exist' do
      before do
        allow(helper).to receive(:matches_exist?).and_return true
      end

      it 'highlights the result count' do
        expect(helper.result_summary).to match(/\A.*bold-term.*4 results.*/)
      end

      context 'unfiltered' do
        it 'outputs expected text including sub-counts' do
          expect(helper.result_summary).to match(/\A.*4 results.* from people \(3\) and teams \(1\)\z/)
        end
      end

      context 'filtered on people' do
        before do
          allow(helper).to receive(:team_count).and_return 0
          @search_filters = ['people']
        end
        it 'outputs expected text, not including sub counts' do
          expect(helper.result_summary).to match(/\A.*3 results.* from people\z/)
        end
      end

      context 'filtered on teams' do
        before do
          allow(helper).to receive(:people_count).and_return 0
          @search_filters = ['teams']
        end
        it 'outputs expected text, not including sub counts' do
          expect(helper.result_summary).to match(/\A.*1 result.* from teams\z/)
        end
      end
    end

    context 'when matches do NOT exist' do
      before do
        @query = 'joel'
        allow(helper).to receive(:matches_exist?).and_return false
      end

      it 'highlights the search term' do
        expect(helper.result_summary).to match(/bold-term.*joel<\/.* not found/)
      end

      context 'unfiltered' do
        before { @search_filters = %w(people teams) }
        it 'outputs expected text, including sub-counts' do
          expect(helper.result_summary).to match(/\A.* not found - 4 similar results from people \(3\) and teams \(1\)\z/)
        end
      end

      context 'filtered on people' do
        before do
          allow(helper).to receive(:team_count).and_return 0
          @search_filters = ['people']
        end
        it 'outputs expected text, not including sub counts' do
          expect(helper.result_summary).to match(/\A.* not found - 3 similar results from people\z/)
        end
      end

      context 'filtered on teams' do
        before do
          allow(helper).to receive(:people_count).and_return 0
          @search_filters = ['teams']
        end
        it 'outputs expected text, not including sub counts' do
          expect(helper.result_summary).to match(/\A.* not found - 1 similar result from teams\z/)
        end
      end

      context 'with no results found' do
        before do
          allow(helper).to receive(:people_count).and_return 0
          allow(helper).to receive(:team_count).and_return 0
        end

        context 'unfiltered' do
          it 'outputs expected text, not including sub counts' do
            expect(helper.result_summary).to match(/\A.* not found - 0 similar results from people and teams\z/)
          end
        end

        context 'filtered on people' do
          before { @search_filters = ['people'] }
          it 'outputs expected text, not including sub counts' do
            expect(helper.result_summary).to match(/\A.* not found - 0 similar results from people\z/)
          end
        end

        context 'filtered on teams' do
          before { @search_filters = ['teams'] }
          it 'outputs expected text, not including sub counts' do
            expect(helper.result_summary).to match(/\A.* not found - 0 similar results from teams\z/)
          end
        end
      end
    end
  end

  describe '#teams_filter?' do
    it 'calls filtered_on?' do
      expect(helper).to receive(:filtered_on?).with 'teams'
      helper.teams_filter?
    end
  end

  describe '#people_filter?' do
    it 'calls filtered_on?' do
      expect(helper).to receive(:filtered_on?).with 'people'
      helper.people_filter?
    end
  end

end
