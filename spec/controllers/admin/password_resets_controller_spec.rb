require 'rails_helper'

RSpec.describe Admin::PasswordResetsController, type: :controller do

  describe 'POST create' do
    let(:admin_user) { create(:admin_user, identities: [create(:identity)]) }
    it 'redirects to admin login screen' do
      post :create, email: admin_user.email
      expect(flash[:notice]).to eq 'Password reset link sent'
      expect(response).to redirect_to(new_login_path)
    end
  end
end
