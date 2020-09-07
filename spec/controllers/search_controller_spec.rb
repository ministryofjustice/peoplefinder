require 'rails_helper'

RSpec.describe SearchController, type: :controller do
  include PermittedDomainHelper

  let(:group) { create(:group) }
  let(:person) { create(:person) }
  let(:person_search) { double(PersonSearch, perform_search: people_results) }
  let(:group_search) { double(GroupSearch, perform_search: team_results) }
  let(:people_results) { double('People results') }
  let(:team_results) { double('Team results') }
  let(:search_filters) { %w(people teams) }

  before do
    mock_logged_in_user
    allow(PersonSearch).to receive(:new).and_return(person_search)
    allow(GroupSearch).to receive(:new).and_return(group_search)
  end

  subject { get :index, params: { query: query, search_filters: search_filters } }

  describe 'GET #index' do
    context 'with valid UTF-8' do
      let(:query) { 'válïd ☺' }

      it 'searches for the query' do
        expect(GroupSearch).to receive(:new).with(query, an_instance_of(SearchResults)).and_return(group_search)
        expect(PersonSearch).to receive(:new).with(query, an_instance_of(SearchResults)).and_return(person_search)
        expect(group_search).to receive(:perform_search)
        expect(person_search).to receive(:perform_search)
        subject
      end

      it 'renders the index template' do
        subject
        expect(response).to render_template(:index)
      end

      it 'assigns people search result to @people_results' do
        subject
        expect(assigns(:people_results)).to eq(people_results)
      end

      it 'assigns team search result to @team_results' do
        subject
        expect(assigns(:team_results)).to eq(team_results)
      end
    end

    context 'with invalid UTF-8' do
      let(:query) { "\x99" }

      it 'searches for an empty string' do
        expect(GroupSearch).to receive(:new).with('', an_instance_of(SearchResults)).and_return(group_search)
        expect(PersonSearch).to receive(:new).with('', an_instance_of(SearchResults)).and_return(person_search)
        subject
      end

      it 'assigns the search result to @people_results' do
        subject
        expect(assigns(:people_results)).to eq(people_results)
      end

      it 'assigns team search result to @team_results' do
        subject
        expect(assigns(:team_results)).to eq(team_results)
      end
    end

    context 'filtering' do
      let(:query) { 'whichever' }
      let(:people_results) { double(SearchResults, set: [person], contains_exact_match: true, size: 1) }
      let(:team_results) { double(SearchResults, set: [group], contains_exact_match: true, size: 1) }

      context 'with defaults' do
        let(:search_filters) { ['people'] }
        it 'searches people only' do
          subject
          expect(assigns(:people_results)).to eq(people_results)
          expect(assigns(:team_results)).to be_nil
        end
      end

      context 'on people and team' do
        let(:search_filters) { %w(people teams) }
        it 'searches people and teams' do
          subject
          expect(assigns(:people_results)).to eq(people_results)
          expect(assigns(:team_results)).to eq(team_results)
        end
      end

      context 'only on teams' do
        let(:search_filters) { ['teams'] }
        it 'searches teams only' do
          subject
          expect(assigns(:people_results)).to be_nil
          expect(assigns(:team_results)).to eq(team_results)
        end
      end
    end

  end
end
