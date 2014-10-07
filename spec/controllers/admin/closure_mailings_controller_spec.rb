require 'rails_helper'

RSpec.describe Admin::ClosureMailingsController, type: :controller do
  before do
    authenticate_as create(:admin_user)
  end

  describe 'POST create' do
    it 'sends closure emails' do
      expect(ReviewPeriod.instance).to receive(:send_closure_notifications)
      post :create
    end

    it 'redirects to the index' do
      post :create
      expect(response).to redirect_to(admin_path)
    end

    it 'shows a success message' do
      post :create
      expect(flash[:notice]).to match(/sent/i)
    end
  end
end
