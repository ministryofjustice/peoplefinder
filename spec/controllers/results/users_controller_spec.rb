require 'rails_helper'
RSpec.describe Results::UsersController, type: :controller do
  let(:me) { create(:user) }

  before do
    authenticate_as me
  end

  describe 'GET index', closed_review_period: true  do
    it 'lists all my managees in alphabetical order' do
      user_a = create(:user, manager: me, name: 'Zelda')
      user_b = create(:user, manager: me, name: 'Ada')
      create(:user)
      get :index

      expect(assigns[:users].to_a).to eql([user_b, user_a])
    end
  end
end
