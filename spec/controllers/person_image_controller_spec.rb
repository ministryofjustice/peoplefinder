require 'rails_helper'

RSpec.describe PersonImageController, :type => :controller do
  before do
    mock_logged_in_user
  end

  describe "GET edit" do
    it "assigns the person" do
      person = Person.create!(surname: 'Doe', image: 'an image')
      get :edit, { person_id: person.to_param }

      expect(assigns(:person)).to eql(person)
    end

    it "redirects when there is no image" do
      person = Person.create!(surname: 'Bloggs', image: nil)
      get :edit, { person_id: person.id }

      expect(response).to be_redirect
      expect(flash[:notice]).to have_text(/No image/)
    end
  end

  describe "PUT update" do
    it 'crops the image' do
      image = double(:image)
      expect(image).to receive(:recreate_versions!).once.and_return(true)

      person = Person.create!(surname: 'Doe', image: image)
      allow_any_instance_of(Person).to receive(:image).and_return(image)

      put :update, { person_id: person.id,
          person: { crop_x: 10, crop_y: 20, crop_w: 200, crop_h: 200 } }

      expect(response).to redirect_to(person)
      expect(flash[:notice]).to have_text("Cropped Doe's image")
    end
  end
end
