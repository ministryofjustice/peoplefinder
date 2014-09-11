require 'rails_helper'
RSpec.describe SubmissionsController, type: :controller do

  let(:author) { create(:user) }
  let!(:submission) { create(:submission, author: author) }

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

      it 'redirects to the replies list' do
        put :update, id: submission.id, submission: valid_attributes
        expect(response).to redirect_to(replies_path)
      end

      it 'changes the submission to submitted' do
        put :update, id: submission.id, submission: valid_attributes
        expect(submission.reload.status).to eql(:submitted)
      end

      it 'changes the submission to started on autosave' do
        put :update,
          id: submission.id, submission: valid_attributes, autosave: 1
        expect(submission.reload.status).to eql(:started)
      end
    end

    context 'without an authenticated session' do
      it 'returns 403 forbidden' do
        put :update, id: submission.id
        expect(response).to be_forbidden
      end
    end
  end

  def valid_attributes
    { rating_1: 1 }
  end
end
