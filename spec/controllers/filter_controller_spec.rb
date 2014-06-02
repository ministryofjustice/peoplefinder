require 'spec_helper'

describe FilterController do

  describe "GET 'index'" do
    let(:user) { create(:user, name: 'admin', email:'admin@admin.com', password: 'password123') }

    context  'as pq user' do
      before do
        sign_in user
      end

      it "returns http success" do
      get 'index'
      response.should be_success
      end
    end
  end
end
