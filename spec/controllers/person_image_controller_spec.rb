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
    it 'assigns the image crop attributes' do
      person = Person.create!(surname: 'Doe', image: 'an image')
      put :update, { crop_x: 10, crop_y: 20, crop_w: 200, crop_h: 200 }

      expect(response).to be_redirect
      expect(flash[:notice]).to have_text("Croppped Doe's image")
    end
  end
end
