require 'rails_helper'

RSpec.describe FeedbackRequestsController, type: :controller do
  let(:author) { create(:user) }
  let(:feedback_request) { create(:feedback_request, author: author) }

  describe 'PUT update' do
    context 'with an authenticated session' do
      before { authenticate_as(author) }

      it 'redirects to the submissions list' do
        put :update, id: feedback_request.id, feedback_request: { status: 'accepted' }
        expect(response).to redirect_to(submissions_path)
      end
    end

    context 'without an authenticated session' do
      it 'returns 403 forbidden' do
        put :update, id: feedback_request.id
        expect(response).to be_forbidden
      end
    end
  end
end
