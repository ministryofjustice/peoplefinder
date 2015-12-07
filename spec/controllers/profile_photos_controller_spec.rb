require 'rails_helper'

RSpec.describe ProfilePhotosController, type: :controller do
  include PermittedDomainHelper

  before do
    mock_logged_in_user
  end

  describe 'POST create' do
    describe 'with valid params' do
      let(:valid_params) { { image: File.open(sample_image) } }
      it 'creates a new ProfilePhoto' do
        expect {
          post :create, profile_photo: valid_params
        }.to change(ProfilePhoto, :count).by(1)
      end

      let(:photo_id)    { 123 }
      let(:photo) { double('photo', to_json: { id: photo_id }.to_json) }

      it 'renders json containing id of the new ProfilePhoto' do
        allow(ProfilePhoto).to receive(:create).and_return(photo)
        post :create, profile_photo: valid_params
        expect(JSON.parse(response.body)['id']).to eq photo_id
      end

      it 'sets return MIME type to "text" to allow iframe target to work with > IE8' do
        allow(ProfilePhoto).to receive(:create).and_return(photo)
        post :create, profile_photo: valid_params
        expect(response.header['Content-Type']).to eq 'text/html; charset=utf-8'
      end
    end
  end
end
