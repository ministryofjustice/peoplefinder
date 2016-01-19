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

  context 'with valid UTF-8' do
    let(:query) { 'válïd ☺' }

    it 'searches for the query' do
      expect(GroupSearch).to receive(:new).with(query).and_return(group_search)
      expect(PersonSearch).to receive(:new).with(query).and_return(person_search)
      get :index, query: query
    end

    it 'assigns people search result to @people' do
      get :index, query: query
      expect(assigns(:people)).to eq(people_results)
    end

    it 'assigns team search result to @teams' do
      get :index, query: query
      expect(assigns(:teams)).to eq(team_results)
    end

    it 'assigns the query to @query' do
      get :index, query: query
      expect(assigns(:query)).to eq(query)
    end
  end

  context 'with invalid UTF-8' do
    let(:query) { "\x99" }

    it 'searches for an empty string' do
      expect(GroupSearch).to receive(:new).with('').and_return(group_search)
      expect(PersonSearch).to receive(:new).with('').and_return(person_search)
      get :index, query: query
    end

    it 'assigns the search result to @people' do
      get :index, query: query
      expect(assigns(:people)).to eq(people_results)
    end

    it 'assigns team search result to @teams' do
      get :index, query: query
      expect(assigns(:teams)).to eq(team_results)
    end

    it 'assigns an empty string to @query' do
      get :index, query: query
      expect(assigns(:query)).to eq('')
    end
  end
end
