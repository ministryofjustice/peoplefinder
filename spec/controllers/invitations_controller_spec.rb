require 'rails_helper'
RSpec.describe InvitationsController, type: :controller do
  let(:author) { create(:user) }
  let!(:invitation) { Invitation.new(create(:review, author: author)) }

  before do
    open_review_period
  end

  describe 'PUT update' do
    context 'with an authenticated session' do
      before do
        authenticate_as(author)
      end

      context 'when accepted' do
        before do
          put :update, id: invitation.id, invitation: { status: :accepted }
        end

        it 'changes the invitation to accepted' do
          expect(invitation.reload.status).to eq(:accepted)
        end

        it 'redirects to edit the review' do
          expect(response).to redirect_to(edit_submission_path(invitation.id))
        end
      end

      context 'when declined with a message' do
        before do
          put :update,
            id: invitation.id,
            invitation: { status: :declined, reason_declined: 'Because' }
        end

        it 'changes the invitation to declined' do
          expect(invitation.reload.status).to eq(:declined)
        end

        it 'redirects to the replies list' do
          expect(response).to redirect_to(replies_path)
        end
      end

      context 'when declined without a message' do
        before do
          put :update, id: invitation.id, invitation: { status: :declined }
        end

        it 'does not change the invitation to declined' do
          expect(invitation.reload.status).to eq(:no_response)
        end

        it 'redirects to the replies list' do
          expect(response).to redirect_to(replies_path)
        end
      end

      context 'when status is invalid' do
        before do
          put :update, id: invitation.id, invitation: { status: :cheese_sandwich }
        end

        it 'returns an error message' do
          expect(request.flash[:error]).to_not be_empty
        end

        it 'redirects to the replies list' do
          expect(response).to redirect_to(replies_path)
        end
      end
    end

    context 'without an authenticated session' do
      it 'returns 403 forbidden' do
        put :update, id: invitation.id
        expect(response).to be_forbidden
      end
    end
  end
end
