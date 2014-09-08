require 'rails_helper'

RSpec.describe Results::ReviewsController, type: :controller do
  let(:me) { create(:user) }
  let(:review) { create(:review, subject: me) }

  before do
    authenticate_as me
  end

  describe 'GET index', closed_review_period: true do
    context 'when the current user receives feedback' do
      before do
        me.update_attributes(manager: create(:user))
        get :index
      end

      it 'assigns existing reviews' do
        expect(assigns(:reviews)).not_to be_nil
      end

      it 'renders the index template' do
        expect(response).to render_template('index')
      end
    end

    context 'when there is no user who receives feedback' do
      before do
        get :index
      end

      it 'redirects to the users page' do
        expect(response).to redirect_to(results_users_path)
      end
    end

    context 'when the input user receives feedback' do
      let(:managee) { create(:user, manager: me) }
      let!(:managee_review) { create(:review, subject: managee) }

      before do
        get :index, user_id: managee.to_param
      end

      it 'renders the index template' do
        expect(response).to render_template('index')
      end

      it 'assigns the reviews' do
        expect(assigns(:reviews)).to include(managee_review)
      end
    end
  end

  context 'when the review period is *not* closed' do
    it 'is forbidden' do
      get :index
      expect(response).to be_forbidden
    end
  end
end
