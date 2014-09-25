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
        me.update manager: create(:user)
      end

      it 'assigns review_aggregator initialised with reviews' do
        aggregator = double(ReviewAggregator)
        expect(ReviewAggregator).to receive(:new).with([review]) { aggregator }
        get :index
        expect(assigns(:review_aggregator)).to eql(aggregator)
      end

      it 'renders the index template' do
        get :index
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
      let(:direct_report) { create(:user, manager: me) }
      let!(:direct_report_review) { create(:review, subject: direct_report) }

      it 'renders the index template' do
        get :index, user_id: direct_report.to_param
        expect(response).to render_template('index')
      end

      it 'assigns review_aggregator initialised with reviews' do
        aggregator = double(ReviewAggregator)
        expect(ReviewAggregator).to receive(:new).with([direct_report_review]) { aggregator }
        get :index, user_id: direct_report.to_param
        expect(assigns(:review_aggregator)).to eql(aggregator)
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
