require 'rails_helper'

RSpec.describe Admin::SettingsController, type: :controller do

  before do
    authenticate_as create(:admin_user)
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates an existing setting' do
        Setting[:FLAVOR] = 'earwax'
        put :update, id: 'FLAVOR', setting: { value: 'raspberry' }
        expect(Setting[:FLAVOR]).to eql('raspberry')
      end

      it 'creates a new setting' do
        put :update, id: 'FLAVOR', setting: { value: 'raspberry' }
        expect(Setting[:FLAVOR]).to eql('raspberry')
      end

      it 'redirects to the admin index' do
        put :update, id: 'FLAVOR', setting: { value: 'raspberry' }
        expect(response).to redirect_to(admin_path)
      end

      it 'shows a success message' do
        put :update, id: 'FLAVOR', setting: { value: 'raspberry' }
        expect(flash[:notice]).to match(/updated setting FLAVOR/i)
      end
    end
  end
end
