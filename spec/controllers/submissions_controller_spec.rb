require 'rails_helper'
RSpec.describe SubmissionsController, type: :controller do

  let(:author) { create(:user) }
  let!(:submission) { create(:started_review, author: author) }
  let(:valid_attributes) { attributes_for(:complete_review) }

  describe 'GET edit' do
    context 'with an authenticated sesssion' do
      before { authenticate_as(author) }

      it 'renders the edit template' do
        get :edit, id: submission.id
        expect(response).to render_template('edit')
      end

      it 'assigns the submission' do
        get :edit, id: submission.id
        expect(assigns(:submission)).to eql(submission)
      end
    end

    context 'without an authenticated session' do
      it 'returns 403 forbidden' do
        get :edit, id: submission.id
        expect(response).to be_forbidden
      end
    end
  end

  describe 'PUT update' do
    context 'with an authenticated session' do
      before do
        authenticate_as(author)
        submission.status = :accepted
        submission.save!
      end

      context 'with a complete submission' do
        before do
          put :update, id: submission.id, submission: valid_attributes
        end

        it 'redirects to the replies list' do
          expect(response).to redirect_to(replies_path)
        end

        it 'changes the submission to submitted' do
          expect(submission.reload.status).to eql(:submitted)
        end

        it 'shows a success message' do
          expect(flash[:notice]).to match(/has been submitted/)
        end
      end

      context 'when autosaving' do
        before do
          put :update,
            id: submission.id, submission: valid_attributes, autosave: 1
        end

        it 'changes the submission to started on autosave' do
          expect(submission.reload.status).to eql(:started)
        end

        it 'does not show a success message' do
          expect(flash[:notice]).to be_nil
        end
      end

      context 'with missing fields' do
        before do
          put :update, id: submission.id, submission: { rating_1: 1 }
        end

        it 're-renders the edit template' do
          expect(response).to render_template('edit')
        end

        it 'shows an error message' do
          expect(flash[:error]).to match(/not submitted/)
        end
      end
    end

    context 'without an authenticated session' do
      it 'returns 403 forbidden' do
        put :update, id: submission.id
        expect(response).to be_forbidden
      end
    end
  end
end
