require 'rails_helper'

RSpec.describe Peoplefinder::MembershipsController, type: :controller do
  routes { Peoplefinder::Engine.routes }

  before do
    mock_logged_in_user
  end

  describe 'DELETE destroy' do
    let(:membership) { create(:membership) }

    it 'deletes the record' do
      delete :destroy, id: membership.to_param, referer: people_path
      expect {
        Peoplefinder::Membership.find(membership)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'redirects to the referer' do
      delete :destroy, id: membership.to_param, referer: people_path
      expect(response).to redirect_to(people_path)
    end
  end
end
