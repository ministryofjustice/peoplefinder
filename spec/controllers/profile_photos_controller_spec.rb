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
        expect do
          post :create, profile_photo: valid_params
        end.to change(ProfilePhoto, :count).by(1)
      end

      describe 'internally' do
        let(:photo_id) { 123 }
        let(:photo) { double('photo', to_json: { id: photo_id }.to_json) }

        before do
          allow(ProfilePhoto).to receive(:create).and_return(photo)
        end

        it 'validates the photo' do
          expect(photo).to receive(:valid?).and_return true
          post :create, profile_photo: valid_params
        end

        it 'renders json containing id of the new ProfilePhoto' do
          allow(photo).to receive(:valid?).and_return true
          post :create, profile_photo: valid_params
          expect(JSON.parse(response.body)['id']).to eq photo_id
        end

        it 'sets return MIME type to "text" to allow iframe target to work with > IE8' do
          allow(photo).to receive(:valid?).and_return true
          post :create, profile_photo: valid_params
          expect(response.header['Content-Type']).to eq 'text/html; charset=utf-8'
        end
      end
    end
  end

  describe 'with invalid params' do
    let(:invalid_params) { { image: File.open(non_white_list_image) } }
    let(:photo_id) { 123 }
    let(:photo) { double('photo', to_json: { id: photo_id }.to_json) }

    before do
      allow(ProfilePhoto).to receive(:create).and_return(photo)
      allow(photo).to receive(:valid?).and_return false
      allow(photo).to receive_message_chain(:errors, :full_messages).and_return ['not a real error', 'nor is this']
    end

    it 'non white listed extensions do not create ProfilePhoto' do
      expect do
        post :create, profile_photo: invalid_params
      end.not_to change(ProfilePhoto, :count)
    end

    it 'renders an error JSON response for use by view' do
      post :create, profile_photo: invalid_params
      expected = { error: "not a real error, nor is this" }.to_json
      expect(response.body).to eql expected
    end

    it 'renders JSON error as text for compatability with IE' do
      post :create, profile_photo: invalid_params
      expect(response.header['Content-Type']).to include 'text/html'
    end
  end

end
