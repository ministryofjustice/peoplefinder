require 'rails_helper'

RSpec.describe TokensController, type: :controller do

  describe 'with a valid user token' do
    let(:user) { create(:user) }

    before do
      token = create(:token, user: user)
      get :show, id: token
    end

    it 'redirects to the dashboard page' do
      expect(response).to redirect_to(dashboard_path)
    end

    it 'sets the user in the session' do
      expect(session[:current_user_id]).to eql(user.id)
    end
  end

  describe 'with a valid review token' do
    let(:review) { create(:review) }

    before do
      token = create(:token, review: review)
      get :show, id: token
    end

    it 'redirects to the edit acceptance page' do
      expect(response).to redirect_to(edit_acceptance_path(review))
    end

    it 'sets the review in the session' do
      expect(session[:review_id]).to eql(review.id)
    end
  end

  describe 'with a bogus token' do
    before do
      get :show, id: 'garbage'
    end

    it 'returns 403 forbidden' do
      expect(response).to be_forbidden
    end
  end
end
