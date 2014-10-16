require 'rails_helper'
RSpec.describe RemindersController, type: :controller do
  let(:review) { create(:review) }

  before do
    open_review_period
  end

  describe 'POST create' do
    context 'with the subject as an authenticated user' do
      before do
        authenticate_as review.subject
      end

      it 'sends a reminder' do
        post :create, review: { review_id: review.id }
        expect(response).to redirect_to(reviews_path)
      end

      it 'redirects to the review list' do
        post :create, review: { review_id: review.id }
        expect(response).to redirect_to(reviews_path)
      end

      it 'shows an information message' do
        post :create, review: { review_id: review.id }
        expect(flash[:notice]).to match(/.+reminder.+/)
      end
    end

    context 'with a different authenticated user' do
      before do
        authenticate_as create(:user)
      end

      it 'returns 403 forbidden' do
        post :create, review: { review_id: review.id }
        expect(response).to be_forbidden
      end
    end
  end
end
