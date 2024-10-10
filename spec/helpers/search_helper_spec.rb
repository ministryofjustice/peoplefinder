require "rails_helper"

# rubocop:disable RSpec/InstanceVariable
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

  describe "#people_count" do
    it "returns 0 or more" do
      expect(helper.people_count).to be 0
    end

    it "returns people results instance variable's size" do
      allow(@people_results).to receive(:set).and_return %w[person1 person2]
      expect(helper.people_count).to be 2
    end
  end

  describe "#team_count" do
    it "returns 0 or more" do
      expect(helper.team_count).to be 0
    end

    it "returns team results instance variable's size" do
      allow(@team_results).to receive(:set).and_return %w[team1 team2 team3]
      expect(helper.team_count).to be 3
    end
  end

  describe "#result_count" do
    it "returns 0 or more" do
      expect(helper.result_count).to be 0
    end

    it "delegates to people and team result set sizes" do
      allow(helper).to receive_messages(people_count: 4, team_count: 1)
      expect(helper.result_count).to eq 5
    end
  end

  describe "#result_summary" do
    before do
      @search_filters = %w[people teams]
      allow(helper).to receive_messages(people_count: 3, team_count: 1)
    end

    context "when matches exist" do
      before do
        allow(helper).to receive(:matches_exist?).and_return true
      end

      it "highlights the result count" do
        expect(helper.result_summary).to match(/\A.*bold-term.*4 results.*/)
      end

      context "when unfiltered" do
        it "outputs expected text including sub-counts" do
          expect(helper.result_summary).to match(/\A.*4 results.* from people \(3\) and teams \(1\)\z/)
        end
      end

      context "when filtered on people" do
        before do
          allow(helper).to receive(:team_count).and_return 0
          @search_filters = %w[people]
        end

        it "outputs expected text, not including sub counts" do
          expect(helper.result_summary).to match(/\A.*3 results.* from people\z/)
        end
      end

      context "when filtered on teams" do
        before do
          allow(helper).to receive(:people_count).and_return 0
          @search_filters = %w[teams]
        end

        it "outputs expected text, not including sub counts" do
          expect(helper.result_summary).to match(/\A.*1 result.* from teams\z/)
        end
      end
    end

    context "when matches do NOT exist" do
      before do
        @query = "joel"
        allow(helper).to receive(:matches_exist?).and_return false
      end

      it "highlights the search term" do
        expect(helper.result_summary).to match(/bold-term.*joel<\/.* not found/)
      end

      context "when unfiltered" do
        before { @search_filters = %w[people teams] }

        it "outputs expected text, including sub-counts" do
          expect(helper.result_summary).to match(/\A.* not found - 4 similar results from people \(3\) and teams \(1\)\z/)
        end
      end

      context "when filtered on people" do
        before do
          allow(helper).to receive(:team_count).and_return 0
          @search_filters = %w[people]
        end

        it "outputs expected text, not including sub counts" do
          expect(helper.result_summary).to match(/\A.* not found - 3 similar results from people\z/)
        end
      end

      context "when filtered on teams" do
        before do
          allow(helper).to receive(:people_count).and_return 0
          @search_filters = %w[teams]
        end

        it "outputs expected text, not including sub counts" do
          expect(helper.result_summary).to match(/\A.* not found - 1 similar result from teams\z/)
        end
      end

      context "with no results found" do
        before do
          allow(helper).to receive_messages(people_count: 0, team_count: 0)
        end

        context "when unfiltered" do
          it "outputs expected text, not including sub counts" do
            expect(helper.result_summary).to match(/\A.* not found - 0 similar results from people and teams\z/)
          end
        end

        context "when filtered on people" do
          before { @search_filters = %w[people] }

          it "outputs expected text, not including sub counts" do
            expect(helper.result_summary).to match(/\A.* not found - 0 similar results from people\z/)
          end
        end

        context "when filtered on teams" do
          before { @search_filters = %w[teams] }

          it "outputs expected text, not including sub counts" do
            expect(helper.result_summary).to match(/\A.* not found - 0 similar results from teams\z/)
          end
        end
      end
    end
  end

  describe "#teams_filter?" do
    it "calls filtered_on?" do
      expect(helper).to receive(:filtered_on?).with "teams"
      helper.teams_filter?
    end
  end

  describe "#people_filter?" do
    it "calls filtered_on?" do
      expect(helper).to receive(:filtered_on?).with "people"
      helper.people_filter?
    end
  end
end
# rubocop:enable RSpec/InstanceVariable
