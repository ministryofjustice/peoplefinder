require 'rails_helper'

RSpec.describe TokensController, type: :controller do

  describe 'with a valid user token' do
    let(:user) { create(:user) }

    before do
      token = create(:token, user: user)
      get :show, id: token
    end

    it 'redirects to the reviews page' do
      expect(response).to redirect_to(reviews_path)
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

    it 'redirects to the replies list' do
      expect(response).to redirect_to(replies_path)
    end

    context 'with a new user' do
      before { User.where(email: review.subject.email).delete_all }

      it 'creates a user and stores the id in the session' do
        expect(session[:current_user_id]).to eql(User.last.id)
      end

      it 'creates a user that is *not* a participant' do
        expect(User.last).not_to be_participant
      end
    end

    context 'with an existing user' do
      it 'finds the user and stores the id in the session' do
        user = User.where(email: review.author_email).first
        expect(session[:current_user_id]).to eql(user.id)
      end
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

  describe 'with an expired token' do
    before do
      token = double(:token)
      allow(token).to receive(:expired?) { false }
      get :show, id: token
    end

    it 'returns 403 forbidden' do
      expect(response).to be_forbidden
    end
  end
end
