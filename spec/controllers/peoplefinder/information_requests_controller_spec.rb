require 'rails_helper'

RSpec.describe Peoplefinder::InformationRequestsController, type: :controller do
  routes { Peoplefinder::Engine.routes }

  before do
    mock_logged_in_user
  end

  let(:person) { create(:person, email: 'someone.else@digital.justice.gov.uk') }

  describe 'GET new' do
    before { get :new, person_id: person.id }

    it 'assigns the person' do
      expect(assigns(:person)).to eql(person)
    end

    it 'assigns a new information request' do
      expect(assigns(:information_request).recipient).to eql(person)
    end

    it 'renders the new template' do
      expect(response).to render_template('new')
    end
  end

  describe 'POST create' do
    context 'with valid params' do
      before do
        post :create, person_id: person.id, information_request: valid_params
      end

      it 'redirects to the recipient profile page' do
        expect(response).to redirect_to(person_path(person))
      end

      it 'sets a flash message' do
        expect(flash[:notice]).to have_text('Your message has been sent')
      end
    end

    context 'with invalid params' do
      before do
        post :create, person_id: person.id, information_request: invalid_params
      end

      it 'renders the new template' do
        expect(response).to render_template('new')
      end
    end
  end

  def valid_params
    {
      message: 'Some stuff'
    }
  end

  def invalid_params
    {
      message: ''
    }
  end
end
