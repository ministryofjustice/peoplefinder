require 'rails_helper'

RSpec.describe SessionsController, :type => :controller do
  describe 'POST create' do
    it 'should flash error and redirect to login page if authentication failed' do
      allow(User).to receive(:from_auth_hash).and_return(nil)
      post :create, {
        "auth_key" => "bogus.user@digital.justice.gov.uk",
        "password" => "Insecure006",
        "provider" => "identity"
      }
      expect(response).to redirect_to('/login')
      expect(flash[:warning]).to have_text(/incorrect/)
    end
  end
end
