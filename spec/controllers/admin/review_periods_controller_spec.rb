require 'rails_helper'

RSpec.describe Admin::ReviewPeriodsController, type: :controller do

  before do
    authenticate_as create(:admin_user)
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the review period closing date/time' do
        put :update, review_period: { closes_at: '2014-10-16 16:08:31 +0100' }
        expect(ReviewPeriod.first.closes_at.to_i).to eql(1413472111)
      end

      it 'redirects to the admin index' do
        put :update, review_period: { closes_at: '2014-10-16 16:08:31 +0100' }
        expect(response).to redirect_to(admin_path)
      end

      it 'shows a success message' do
        put :update, review_period: { closes_at: '2014-10-16 16:08:31 +0100' }
        expect(flash[:notice]).to match(/updated review period/i)
      end
    end
  end
end
