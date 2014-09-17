require 'rails_helper'
RSpec.describe ReviewsController, type: :controller do
  let(:me) { create(:user) }

  let(:valid_attributes) {
    {
      relationship: 'Colleague',
      author_email: 'danny@example.com',
      author_name: 'Danny Boy',
      relationship: 'peer'
    }
  }

  describe 'GET index' do
    before do
      authenticate_as me
    end

    describe 'when the current user receives feedback' do
      before do
        me.update_attributes(manager: create(:user))
        get :index
      end

      it 'assigns a new review' do
        expect(assigns(:review)).to be_a(Review)
      end

      it 'assigns existing reviews' do
        expect(assigns(:reviews)).not_to be_nil
      end

      it 'renders the index template' do
        expect(response).to render_template('index')
      end
    end

    describe 'when there is no user who receives feedback' do
      before do
        get :index
      end

      it 'redirects to the users page' do
        expect(response).to redirect_to(users_path)
      end
    end

    describe 'when the input user receives feedback' do
      before do
        direct_report = create(:user, manager: me)
        get :index, user_id: direct_report.to_param
      end

      it 'renders the index template' do
        expect(response).to render_template('index')
      end
    end
  end

  describe 'POST create' do
    before do
      authenticate_as me
    end

    describe 'with valid params and implicit subject' do
      it 'creates a new Review' do
        expect {
          post :create, review: valid_attributes
        }.to change(Review, :count).by(1)
      end

      it 'redirects back to the index' do
        post :create, review: valid_attributes
        expect(response).to redirect_to(reviews_path)
      end

      it 'assigns the review to me' do
        post :create, review: valid_attributes
        expect(Review.last.subject).to eql(me)
      end

      it 'shows an information message' do
        post :create, review: valid_attributes
        expect(flash[:notice]).to match(/Invited Danny Boy/)
      end
    end

    describe 'with valid params and explicit subject' do
      let(:direct_report) { create(:user, manager: me) }

      it 'creates a new Review' do
        expect {
          post :create, user_id: direct_report.to_param, review: valid_attributes
        }.to change(Review, :count).by(1)
      end

      it 'redirects back to the index' do
        post :create, user_id: direct_report.to_param, review: valid_attributes
        expect(response).to redirect_to(user_reviews_path(direct_report))
      end

      it 'assigns the review to the direct report' do
        post :create, user_id: direct_report.to_param, review: valid_attributes
        expect(Review.last.subject).to eql(direct_report)
      end

      it 'shows an information message' do
        post :create, user_id: direct_report.to_param, review: valid_attributes
        expect(flash[:notice]).to match(/Invited Danny Boy/)
      end

      it 'checks that the subject is a direct report of the current user' do
        third_party = create(:user)
        expect {
          post :create, user_id: third_party.to_param, review: valid_attributes
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe 'with invalid params' do
      before do
        post :create, review: { author_email: '' }
      end

      it 'assigns a newly created but unsaved review as @review' do
        expect(assigns(:review)).to be_a_new(Review)
      end

      it 're-renders the index template' do
        expect(response).to render_template('index')
      end

      it 'shows an error message' do
        expect(flash[:error]).to match(/errors/)
      end
    end
  end

  describe 'GET show' do
    before do
      authenticate_as me
    end

    describe 'with a non-existent review' do

      it 'raises a not found exception' do
        expect {
          get :show, id: 999
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    describe 'as the subject of the review' do
      let(:review) { create(:review, subject: me) }

      describe 'with a review that has been submitted' do
        before do
          review.update_attributes(status: :submitted)
          get :show, id: review.to_param
        end

        it 'assigns the review' do
          expect(assigns(:review)).to eql(review)
        end

        it 'renders the show template' do
          expect(response).to render_template('show')
        end
      end

      describe 'with a review that has not been submitted' do
        it 'raises a not found exception' do
          review.update_attributes(status: :started)
          expect {
            get :show, id: review.to_param
          }.to raise_exception(ActiveRecord::RecordNotFound)
        end
      end
    end

    describe 'as the manager of the subject of the review' do
      let(:review) { create(:review, subject: subject) }
      let(:subject) { create(:user, manager: me) }

      describe 'with a review that has been submitted' do
        before do
          review.update_attributes(status: :submitted)
          get :show, user_id: subject.to_param, id: review.to_param
        end

        it 'assigns the review' do
          expect(assigns(:review)).to eql(review)
        end

        it 'renders the show template' do
          expect(response).to render_template('show')
        end
      end

      describe 'with a review that has not been submitted' do
        it 'raises a not found exception' do
          review.update_attributes(status: :started)
          expect {
            get :show, id: review.to_param
          }.to raise_exception(ActiveRecord::RecordNotFound)
        end
      end
    end

    describe 'as the author of the review' do
      let(:review) { create(:review, author_email: me.email) }

      describe 'with a review that has been submitted' do
        before do
          review.update_attributes(status: :submitted)
          get :show, id: review.to_param
        end

        it 'assigns the review' do
          expect(assigns(:review)).to eql(review)
        end

        it 'renders the show template' do
          expect(response).to render_template('show')
        end
      end
    end
  end
end
