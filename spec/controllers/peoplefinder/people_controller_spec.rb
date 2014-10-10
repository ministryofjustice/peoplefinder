require 'rails_helper'

RSpec.describe Peoplefinder::PeopleController, type: :controller do
  routes { Peoplefinder::Engine.routes }

  before do
    mock_logged_in_user
  end

  # This should return the minimal set of attributes required to create a valid
  # Person. As you add validations to Person, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    attributes_for(:person)
  }

  let(:invalid_attributes) {
    { surname: '' }
  }

  let(:valid_attributes_with_image) {
    attributes_for(:person).merge(image: File.open(sample_image))
  }

  let(:group) { create(:group) }

  describe 'GET index' do
    it 'redirects to the root' do
      get :index, {}
      expect(response).to redirect_to('/')
    end
  end

  describe 'GET show' do
    it 'assigns the requested person as @person' do
      person = create(:person, valid_attributes)
      get :show, id: person.to_param
      expect(assigns(:person)).to eq(person)
    end
  end

  describe 'GET new' do
    it 'assigns a new person as @person' do
      get :new, {}
      expect(assigns(:person)).to be_a_new(Peoplefinder::Person)
    end

    it 'builds a membership object' do
      get :new, {}
      expect(assigns(:person).memberships.length).to eql(1)
    end

    it 'sets groups' do
      get :new, {}
      expect(assigns(:groups)).to include(group)
    end
  end

  describe 'GET edit' do
    let(:person) { create(:person, valid_attributes) }

    it 'assigns the requested person as @person' do
      get :edit, id: person.to_param
      expect(assigns(:person)).to eq(person)
    end

    it 'sets groups' do
      get :edit, id: person.to_param
      expect(assigns(:groups)).to include(group)
    end

    context 'building memberships' do
      it 'builds a membership if there isn\'t one already' do
        get :edit, id: person.to_param
        expect(assigns(:person).memberships.length).to eql(1)
      end

      it 'does not build a membership when there is one already' do
        person.memberships.create(group: group)
        get :edit, id: person.to_param
        expect(assigns(:person).memberships.length).to eql(1)
      end
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new Person' do
        expect {
          post :create, person: valid_attributes
        }.to change(Peoplefinder::Person, :count).by(1)
      end

      it 'assigns a newly created person as @person' do
        post :create, person: valid_attributes
        expect(assigns(:person)).to be_a(Peoplefinder::Person)
        expect(assigns(:person)).to be_persisted
      end

      it 'redirects to the created person' do
        post :create, person: valid_attributes
        expect(response).to redirect_to(Peoplefinder::Person.last)
      end
    end

    describe 'with an attached image' do
      before do
        post :create, person: valid_attributes_with_image
      end

      it 'redirects to the cropping tool' do
        expect(response).to redirect_to(edit_person_image_path(Peoplefinder::Person.last))
      end
    end

    describe 'with invalid params' do
      before do
        post :create, person: invalid_attributes
      end

      it 'assigns a newly created but unsaved person as @person' do
        expect(assigns(:person)).to be_a_new(Peoplefinder::Person)
      end

      it 're-renders the new template' do
        expect(response).to render_template('new')
      end

      it 'assigns the @groups collection' do
        expect(assigns(:groups)).to include(group)
      end

      it 'shows an error message' do
        expect(flash[:error]).to match(/created/)
      end
    end

    describe 'with duplicate name' do
      it 'renders the confirm template' do
        create(:person, given_name: 'Bo', surname: 'Diddley')
        post :create, person: { given_name: 'Bo', surname: 'Diddley' }
        expect(response).to render_template('confirm')
      end
    end
  end

  describe 'PUT update' do
    let(:person) { create(:person, valid_attributes) }

    describe 'with valid params' do
      let(:new_attributes) {
        attributes_for(:person).merge(
          works_monday: true,
          works_tuesday: false,
          works_saturday: true,
          works_sunday: false
        )
      }

      before do
        put :update, id: person.to_param, person: new_attributes
      end

      it 'updates the requested person' do
        person.reload
        new_attributes.each do |attr, value|
          expect(person.send(attr)).to eql(value)
        end
      end

      it 'assigns the requested person as @person' do
        expect(assigns(:person)).to eq(person)
      end

      it 'redirects to the person' do
        expect(response).to redirect_to(person)
      end
    end

    describe 'with an attached image' do
      before do
        put :update, id: person.to_param, person: valid_attributes_with_image
      end

      it 'redirects to the cropping tool' do
        expect(response).to redirect_to(edit_person_image_path(person))
      end
    end

    describe 'with invalid params' do
      before do
        put :update, id: person.to_param, person: invalid_attributes
      end

      it 'assigns the person as @person' do
        expect(assigns(:person)).to eq(person)
      end

      it 're-renders the edit template' do
        expect(response).to render_template('edit')
      end

      it 'assigns the @groups collection' do
        expect(assigns(:groups)).to include(group)
      end

      it 'shows an error message' do
        expect(flash[:error]).to match(/update/)
      end
    end

    describe 'with duplicate name' do
      it 'renders the confirm template' do
        create(:person, given_name: 'Bo', surname: 'Diddley')
        person = create(:person, given_name: 'Bobbie', surname: 'Browne')
        put :update, id: person.to_param, person: { given_name: 'Bo', surname: 'Diddley' }
        expect(response).to render_template('confirm')
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested person' do
      person = create(:person, valid_attributes)
      expect {
        delete :destroy, id: person.to_param
      }.to change(Peoplefinder::Person, :count).by(-1)
    end

    it 'redirects to the people list' do
      person = create(:person, valid_attributes)
      delete :destroy, id: person.to_param
      expect(response).to redirect_to(home_path)
    end

    it 'sets a flash message' do
      person = create(:person, valid_attributes)
      delete :destroy, id: person.to_param
      expect(flash[:notice]).to include("Deleted #{person}’s profile")
    end
  end

  describe 'GET add_membership' do
    context 'with a new person' do
      it 'renders add_membership template' do
        get :add_membership
        expect(response).to render_template('add_membership')
      end

      it 'sets groups' do
        get :add_membership
        expect(assigns(:groups)).to include(group)
      end
    end

    context 'with an existing person' do
      let(:person) { create(:person) }

      it 'renders add_membership template' do
        get :add_membership, id: person
        expect(response).to render_template('add_membership')
      end

      it 'sets groups' do
        get :add_membership, id: person
        expect(assigns(:groups)).to include(group)
      end
    end
  end
end
