require 'rails_helper'

RSpec.describe MembershipsController, :type => :controller do
  before do
    mock_logged_in_user
  end

  describe "DELETE destroy" do
    let(:group) { create(:membership) }

    it "redirects to the referer list" do
      delete :destroy, {:id => group.to_param, referer: people_path}
      expect(response).to redirect_to(people_path)
    end
  end
end
