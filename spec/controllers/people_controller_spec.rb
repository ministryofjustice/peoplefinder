require 'rails_helper'

RSpec.describe PeopleController, type: :controller do
  include PermittedDomainHelper

  before do
    mock_logged_in_user
  end

  # This should return the minimal set of attributes required to create a valid
  # Person. As you add validations to Person, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    attributes_for(:person)
  end

  let(:invalid_attributes) do
    { surname: '' }
  end

  let(:valid_attributes_with_image) do
    attributes_for(:person).merge(image: File.open(sample_image))
  end

  let!(:group) { create(:group) }

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
      expect(assigns(:person)).to be_a_new(Person)
    end

    it 'builds a membership object' do
      get :new, {}
      expect(assigns(:person).memberships.length).to eql(1)
    end
  end

  describe 'GET edit' do
    let(:person) { create(:person, valid_attributes) }

    it 'assigns the requested person as @person' do
      get :edit, id: person.to_param
      expect(assigns(:person)).to eq(person)
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
        expect do
          post :create, person: valid_attributes
        end.to change(Person, :count).by(1)
      end

      it 'assigns a newly created person as @person' do
        post :create, person: valid_attributes
        expect(assigns(:person)).to be_a(Person)
        expect(assigns(:person)).to be_persisted
      end

      it 'redirects to the created person' do
        attributes = valid_attributes
        email = attributes[:email]
        post :create, person: attributes
        expect(response).to redirect_to(Person.find_by_email(email))
      end
    end

    describe 'with invalid params' do
      before do
        post :create, person: invalid_attributes
      end

      it 'assigns a newly created but unsaved person as @person' do
        expect(assigns(:person)).to be_a_new(Person)
      end

      it 're-renders the new template' do
        expect(response).to render_template('new')
      end

      it 'shows an error message' do
        expect(flash[:error]).to match(/created/)
      end
    end

    describe 'with duplicate name' do
      it 'renders the confirm template' do
        create(:person, given_name: 'Bo', surname: 'Diddley')
        post :create, person: { given_name: 'Bo', surname: 'Diddley', email: person_attributes[:email] }
        expect(response).to render_template('confirm')
      end
    end

    describe 'when trying to create a super admin' do
      subject { assigns(:person) }
      before do
        post :create, person: attributes_for(:super_admin)
      end

      it 'creates the person' do
        is_expected.to be_persisted
      end

      it 'creates person, but not as super admin' do
        is_expected.not_to be_super_admin
      end
    end
  end

  describe 'PUT update myself' do
    let(:person) { current_user }

    before do
      put :update, id: person.to_param, person: new_attributes
    end

    describe 'with valid params' do
      let(:new_attributes) do
        attributes_for(:person).merge(works_monday: true, works_tuesday: false)
      end

      it 'shows no notice about informing the person' do
        expect(flash[:notice]).not_to match(/We have let/)
        expect(flash[:notice]).to match(/Updated your profile/)
      end
    end

    describe 'when trying to grant super admin' do
      let(:new_attributes) do
        attributes_for(:person).merge(super_admin: true)
      end

      it 'does not grant super admin privileges' do
        person.reload

        expect(person).not_to be_super_admin
      end
    end
  end

  describe 'PUT update a third party' do
    let(:person) { create(:person, valid_attributes) }

    describe 'with valid params' do
      let(:new_attributes) do
        attributes_for(:person).merge(
          works_monday: true,
          works_tuesday: false,
          works_saturday: true,
          works_sunday: false
        )
      end

      before do
        put :update, id: person.to_param, person: new_attributes
      end

      it 'updates the requested person apart from e-mail' do
        person.reload
        new_attributes.each do |attr, value|
          if attr != :email
            expect(person.send(attr)).to eql(value)
          end
        end
      end

      it 'does not update e-mail' do
        person.reload

        expect(person.email).not_to eql(new_attributes[:email])
      end

      it 'assigns the requested person as @person' do
        expect(assigns(:person)).to eq(person)
      end

      it 'redirects to the person' do
        expect(response).to redirect_to(person)
      end

      it 'shows a notice about informing the person' do
        expect(flash[:notice]).to match(/We have let/)
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
    end

    describe 'with duplicate name' do
      it 'renders the confirm template' do
        create(:person, given_name: 'Bo', surname: 'Diddley')
        person = create(:person, given_name: 'Bobbie', surname: 'Browne')
        put :update, id: person.to_param, person: { given_name: 'Bo', surname: 'Diddley' }
        expect(response).to render_template('confirm')
      end
    end

    describe 'when trying to grant super admin privileges' do
      let(:attributes_with_super_admin) do
        attributes_for(:super_admin)
      end

      before do
        put :update, id: person.to_param, person: attributes_with_super_admin
      end

      it 'does not grant super admin privileges' do
        person.reload

        expect(person).not_to be_super_admin
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested person' do
      person = create(:person, valid_attributes)
      expect do
        delete :destroy, id: person.to_param
      end.to change(Person, :count).by(-1)
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
    end

    context 'with an existing person' do
      let(:person) { create(:person) }

      it 'renders add_membership template' do
        get :add_membership, id: person
        expect(response).to render_template('add_membership')
      end
    end
  end
end
