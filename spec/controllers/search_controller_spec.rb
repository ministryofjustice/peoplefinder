require 'rails_helper'

RSpec.describe SearchController, type: :controller do
  include PermittedDomainHelper

  let(:person_search) { double(PersonSearch, perform_search: people_results) }
  let(:group_search)  { double(GroupSearch, perform_search: team_results) }

  let(:people_results) { double('People results') }
  let(:team_results)   { double('Team results') }

  before do
    mock_logged_in_user
    allow(PersonSearch).to receive(:new).and_return(person_search)
    allow(GroupSearch).to receive(:new).and_return(group_search)
  end

  subject { get :index, query: query }

  describe 'GET #index - rendering' do
    render_views

    let(:query) { 'whichever' }
    let(:group) { create(:group) }
    let(:person) { create(:person) }
    let(:people_results) { double(SearchResults, set: [person], contains_exact_match: true, size: 1) }
    let(:team_results) { double(SearchResults, set: [group], contains_exact_match: true, size: 1) }

    it 'renders the index template' do
      subject
      expect(response).to render_template(:index)
    end

    it 'template calls matches_exist?' do
      expect(controller).to receive(:matches_exist?)
      subject
    end

    it 'assigns @query for use in view' do
      subject
      expect(assigns(:team_results)).to eq(team_results)
    end
  end

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

  end
end
