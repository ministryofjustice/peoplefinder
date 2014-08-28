require 'rails_helper'
RSpec.describe AcceptancesController, type: :controller do
  let(:author) { create(:user) }
  let(:acceptance) { create(:acceptance, author: author) }

  describe 'GET edit' do
    context 'with an authenticated sesssion' do
      before { authenticate_as(author) }

      it 'assigns the review as an acceptance' do
        get :edit, id: acceptance.id
        expect(assigns(:acceptance)).to eql(acceptance)
      end

      it 'renders the edit template' do
        get :edit, id: acceptance.id
        expect(response).to render_template('edit')
      end
    end

    context 'without an authenticated session' do
      it 'returns 403 forbidden' do
        get :edit, id: acceptance.id
        expect(response).to be_forbidden
      end
    end
  end

  describe 'PUT update' do
    context 'with an authenticated session' do
      before { authenticate_as(author) }

      it 'redirects to the submissions list' do
        put :update, id: acceptance.id, acceptance: { status: 'accepted' }
        expect(response).to redirect_to(submissions_path)
      end
    end

    context 'without an authenticated session' do
      it 'returns 403 forbidden' do
        put :update, id: acceptance.id
        expect(response).to be_forbidden
      end
    end
  end
end
