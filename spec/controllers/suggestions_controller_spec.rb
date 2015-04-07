require 'rails_helper'

RSpec.describe SuggestionsController, type: :controller do
  include PermittedDomainHelper

  before do
    mock_logged_in_user
  end

  describe 'GET new' do
    let(:person_id)  { 'person-id' }
    let(:person)     { double('person') }
    let(:suggestion) { double('suggestion') }
    let(:friendly)   { double('friendly') }

    it 'assigns a new suggestion as @suggestion' do
      expect(Suggestion).to receive(:new).and_return(suggestion)
      allow(Person).to receive(:friendly).and_return(friendly)
      allow(friendly).to receive(:find).with(person_id).and_return(person)

      get :new, person_id: person_id

      expect(assigns(:suggestion)).to eq suggestion
    end

    it 'assigns loaded person to @person' do
      allow(Suggestion).to receive(:new).and_return(suggestion)
      expect(Person).to receive(:friendly).and_return(friendly)
      expect(friendly).to receive(:find).with(person_id).and_return(person)

      get :new, person_id: person_id

      expect(assigns(:person)).to eq person
    end
  end

  describe 'POST create' do
    let(:params)     { { foo: 'bar' } }
    describe 'invalid suggestion' do
      let(:suggestion) { double('suggestion', :'valid?' => false) }

      it 'renders the form' do
        expect(Suggestion).to receive(:new).with(params).and_return(suggestion)
        post :create, person_id: 'foo', suggestion: params
        expect(response).to render_template(:new)
      end
    end

    describe 'valid suggestion' do
      let(:person_id)  { 'person-id' }
      let(:person)     { double('person') }
      let(:friendly)   { double('friendly') }
      let(:suggestion) { double('suggestion', :'valid?' => true) }

      it 'delivers the suggestion' do
        expect(Suggestion).to receive(:new).with(params).and_return(suggestion)
        expect(Person).to receive(:friendly).and_return(friendly)
        expect(friendly).to receive(:find).with(person_id).and_return(person)
        expect(SuggestionDelivery).to receive(:deliver).with(person, current_user, suggestion)

        post :create, person_id: person_id, suggestion: params

        expect(response).to render_template(:create)
      end
    end
  end
end
