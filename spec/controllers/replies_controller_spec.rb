require 'rails_helper'
RSpec.describe RepliesController, type: :controller do

  let(:author) { create(:user) }
  let!(:reply) { create(:reply, author: author) }
  describe 'GET index' do
    context 'with an authenticated sesssion' do
      before { authenticate_as(author) }

      it 'renders the index template' do
        get :index
        expect(response).to render_template('index')
      end

      it 'assigns the replies' do
        get :index
        expect(assigns(:replies)).to include(reply)
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
