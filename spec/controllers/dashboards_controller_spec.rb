require 'rails_helper'

RSpec.describe DashboardsController, type: :controller do

  describe 'with a user id in the session' do
    let(:user) { create(:user) }

    before do
      authenticate_as user
      get :show
    end

    it 'returns 200 OK' do
      expect(response.status).to eql(200)
    end
  end

  describe 'without a user' do
    before do
      get :show
    end

    it 'returns 500 forbidden' do
      expect(response.status).to eql(500)
    end
  end
end
