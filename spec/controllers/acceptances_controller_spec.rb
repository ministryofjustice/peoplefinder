require 'rails_helper'
RSpec.describe AcceptancesController, type: :controller do
  let(:author) { create(:user) }
  let(:review) { create(:review, author: author) }

  describe 'GET edit' do
    let(:review) { create(:review) }

    context 'with an authenticated sesssion' do
      before { authenticate_as(author) }

      it 'renders the edit template' do
        get :edit, id: review.id
        expect(response).to render_template('edit')
      end
    end

    context 'without an authenticated session' do
      it 'returns 403 forbidden' do
        get :edit, id: review.id
        expect(response).to be_forbidden
      end
    end
  end

  describe 'PUT update' do
    let(:review) { create(:review) }

    context 'with an authenticated session' do
      before { authenticate_as(author) }

      it 'redirects to the submissions list' do
        put :update, id: review.id, review: { status: 'accepted' }
        expect(response).to redirect_to(submissions_path)
      end
    end

    context 'without an authenticated session' do
      it 'returns 403 forbidden' do
        put :update, id: review.id
        expect(response).to be_forbidden
      end
    end
  end
end
