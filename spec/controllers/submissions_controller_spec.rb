require 'rails_helper'
RSpec.describe SubmissionsController, type: :controller do

  describe 'GET index' do
    let(:author) { create(:user) }
    let!(:review) { create(:review, author: author) }

    context 'with an authenticated sesssion' do
      before { authenticate_as(author) }

      it 'renders the index template' do
        get :index
        expect(response).to render_template('index')
      end

      it 'assigns the submissions' do
        get :index
        expect(assigns(:submissions)).to include(review)
      end
    end

    context 'without an authenticated session' do
      it 'returns 403 forbidden' do
        get :index
        expect(response).to be_forbidden
      end
    end
  end
end
