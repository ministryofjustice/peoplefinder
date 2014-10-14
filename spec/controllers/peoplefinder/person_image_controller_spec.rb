require 'rails_helper'

RSpec.describe Peoplefinder::PersonImageController, type: :controller do
  routes { Peoplefinder::Engine.routes }

  before do
    mock_logged_in_user
  end

  describe 'GET edit' do
    it 'assigns the person' do
      person = create(:person, surname: 'Doe', image: 'an image')
      get :edit, person_id: person.to_param

      expect(assigns(:person)).to eql(person)
    end

    it 'redirects when there is no image' do
      person = create(:person, surname: 'Bloggs', image: nil)
      get :edit, person_id: person.id

      expect(response).to be_redirect
      expect(flash[:notice]).to have_text(/No image/)
    end
  end

  describe 'PUT update' do
    let(:image) { double(:image) }
    let(:person) { create(:person, surname: 'Doe', image: image) }

    it 'recreates image versions' do
      expect(image).to receive(:recreate_versions!).once.and_return(true)
      allow_any_instance_of(Peoplefinder::Person).to receive(:image).and_return(image)

      put :update,
        person_id: person.id,
        person: { crop_x: 10, crop_y: 20, crop_w: 200, crop_h: 200 }

      expect(response.header['Location']).to include(person_path(person, cache_bust: ''))
      expect(flash[:notice]).to have_text('Cropped Doe’s image')
    end

    it 'fails to recreate image versions' do
      expect(image).to receive(:recreate_versions!).once.and_return(false)
      allow_any_instance_of(Peoplefinder::Person).to receive(:image).and_return(image)

      put :update,
        person_id: person.id,
        person: { crop_x: 10, crop_y: 20, crop_w: 200, crop_h: 200 }

      expect(response).to render_template(:edit)

      expect(flash[:error]).to match(/error/)
    end
  end
end
