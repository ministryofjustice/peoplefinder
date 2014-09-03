require 'rails_helper'

RSpec.describe Results::ReviewsController, type: :controller do
  let(:me) { create(:user) }
  let(:review) { create(:review, subject: me) }

  before do
    authenticate_as me
  end

  describe 'GET index', closed_review_period: true do
    before { get :index }

    it 'renders the index template' do
      expect(response).to render_template('index')
    end

    it 'assigns the reviews' do
      expect(assigns(:reviews)).to include(review)
    end
  end

  context 'when the review period is *not* closed' do
    it 'should be forbidden' do
      get :index
      expect(response).to be_forbidden
    end
  end
end
