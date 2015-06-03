require 'rails_helper'

RSpec.describe SearchController, type: :controller do
  include PermittedDomainHelper

  let(:search) {
    double(PersonSearch, fuzzy_search: search_result)
  }

  let(:search_result) {
    double('Elasticsearch result')
  }

  before do
    mock_logged_in_user
    allow(PersonSearch).to receive(:new).and_return(search)
  end

  context 'with valid UTF-8' do
    let(:query) { 'válïd ☺' }

    it 'searches for the query' do
      expect(search).to receive(:fuzzy_search).with(query).
        and_return(search_result)
      get :index, query: query
    end

    it 'assigns the search result to @people' do
      get :index, query: query
      expect(assigns(:people)).to eq(search_result)
    end

    it 'assigns the query to @query' do
      get :index, query: query
      expect(assigns(:query)).to eq(query)
    end
  end

  context 'with invalid UTF-8' do
    let(:query) { "\x99" }

    it 'searches for an empty string' do
      expect(search).to receive(:fuzzy_search).with('').
        and_return(search_result)
      get :index, query: query
    end

    it 'assigns the search result to @people' do
      get :index, query: query
      expect(assigns(:people)).to eq(search_result)
    end

    it 'assigns an empty string to @query' do
      get :index, query: query
      expect(assigns(:query)).to eq('')
    end
  end
end
