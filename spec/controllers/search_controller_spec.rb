require "rails_helper"

RSpec.describe SearchController, type: :controller do
  include PermittedDomainHelper

  subject(:get_index) { get :index, params: { query:, search_filters: } }

  let(:group) { create(:group) }
  let(:person) { create(:person) }
  let(:person_search) { instance_double(PersonPgSearch, perform_search: people_results) }
  let(:group_search)  { instance_double(GroupSearch, perform_search: team_results) }
  let(:people_results) { PgSearchResults.new }
  let(:team_results)   { PgSearchResults.new }
  let(:search_filters) { %w[people teams] }

  before do
    mock_logged_in_user
    allow(PersonPgSearch).to receive(:new).and_return(person_search)
    allow(GroupSearch).to receive(:new).and_return(group_search)
  end

  describe "GET #index" do
    context "with valid UTF-8" do
      let(:query) { "válïd ☺" }

      it "searches using PgSearchResults" do
        allow(GroupSearch).to receive(:new).with(query, an_instance_of(PgSearchResults)).and_return(group_search)
        allow(PersonPgSearch).to receive(:new).with(query, an_instance_of(PgSearchResults)).and_return(person_search)
        expect(group_search).to receive(:perform_search)
        expect(person_search).to receive(:perform_search)
        get_index
      end

      it "renders the index template" do
        get_index
        expect(response).to render_template(:index)
      end

      it "assigns people search result to @people_results" do
        get_index
        expect(assigns(:people_results)).to eq(people_results)
      end

      it "assigns team search result to @team_results" do
        get_index
        expect(assigns(:team_results)).to eq(team_results)
      end
    end

    context "when filtering" do
      let(:query) { "whichever" }
      let(:people_results) { PgSearchResults.new(set: [person], contains_exact_match: true) }
      let(:team_results)   { PgSearchResults.new(set: [group],  contains_exact_match: true) }

      context "with defaults" do
        let(:search_filters) { %w[people] }

        it "searches people only" do
          get_index
          expect(assigns(:people_results)).to eq(people_results)
          expect(assigns(:team_results)).to be_nil
        end
      end

      context "with people and teams" do
        let(:search_filters) { %w[people teams] }

        it "searches people and teams" do
          get_index
          expect(assigns(:people_results)).to eq(people_results)
          expect(assigns(:team_results)).to eq(team_results)
        end
      end

      context "with only teams" do
        let(:search_filters) { %w[teams] }

        it "searches teams only" do
          get_index
          expect(assigns(:people_results)).to be_nil
          expect(assigns(:team_results)).to eq(team_results)
        end
      end
    end
  end
end
