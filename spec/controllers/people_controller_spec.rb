require 'rails_helper'

RSpec.describe PeopleController, :type => :controller do
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
    {surname: ''}
  }

  let(:valid_attributes_with_image) {
    attributes_for(:person).merge(image: File.open(sample_image))
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # PersonsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let(:group) { create(:group) }

  describe "GET index" do
    it "assigns all people as @people" do
      person = Person.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:people)).to eq([person])
    end
  end

  describe "GET show" do
    it "assigns the requested person as @person" do
      person = Person.create! valid_attributes
      get :show, {:id => person.to_param}, valid_session
      expect(assigns(:person)).to eq(person)
    end
  end

  describe "GET new" do
    it "assigns a new person as @person" do
      get :new, {}, valid_session
      expect(assigns(:person)).to be_a_new(Person)
    end

    it "builds a membership object" do
      get :new, {}, valid_session
      expect(assigns(:person).memberships.length).to eql(1)
    end

    it "sets assignable groups" do
      get :new, {}, valid_session
      expect(assigns(:person).assignable_groups).to eql(assigns(:groups))
    end
  end

  describe "GET edit" do
    it "assigns the requested person as @person" do
      person = Person.create! valid_attributes
      get :edit, {:id => person.to_param}, valid_session
      expect(assigns(:person)).to eq(person)
      expect(assigns(:person).assignable_groups).to eql(assigns(:groups))
    end

    context 'building memberships' do
      let(:person) { create(:person) }

      it "builds a membership if there isn't one already" do
        get :edit, {:id => person.to_param}, valid_session
        expect(assigns(:person).memberships.length).to eql(1)
      end

      it " does not build a membership when there is one already" do
        person.memberships.create(group: group)
        get :edit, {:id => person.to_param}, valid_session
        expect(assigns(:person).memberships.length).to eql(1)
      end
    end
  end

  describe 'GET add_membership' do
    context 'with a new person' do
      it 'builds a membership for a person object and renders add_membership template' do
        get :add_membership
        expect(assigns(:person).memberships.length).to eql(1)
        expect(response).to render_template('add_membership')
      end
    end

    context 'with an existing person' do
      let(:person) { create(:person) }

      it 'builds a membership for a person object and renders add_membership template' do
        get :add_membership, id: person
        expect(assigns(:person).memberships.length).to eql(1)
        expect(response).to render_template('add_membership')
      end

      it 'sets assignable groups' do
        group = create(:group)
        get :add_membership, id: person
        expect(assigns(:groups)).to include(group)
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Person" do
        expect {
          post :create, {:person => valid_attributes}, valid_session
        }.to change(Person, :count).by(1)
      end

      it "assigns a newly created person as @person" do
        post :create, {:person => valid_attributes}, valid_session
        expect(assigns(:person)).to be_a(Person)
        expect(assigns(:person)).to be_persisted
      end

      it "redirects to the created person" do
        post :create, {:person => valid_attributes}, valid_session
        expect(response).to redirect_to(Person.last)
      end

      it "redirect to the cropping tool if an image has been attached" do
        post :create, {:person => valid_attributes_with_image}, valid_session
        expect(response).to redirect_to(edit_person_image_path(Person.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved person as @person" do
        post :create, {:person => invalid_attributes}, valid_session
        expect(assigns(:person)).to be_a_new(Person)
      end

      it "re-renders the 'new' template" do
        post :create, {:person => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end

      it "assigns the @groups collection" do
        post :create, {:person => invalid_attributes}, valid_session
        expect(assigns(:person).assignable_groups).to eql(assigns(:groups))
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      let(:new_attributes) {
        attributes_for(:person).merge(
          works_monday: true,
          works_tuesday: false,
          works_saturday: true,
          works_sunday: false
        )
      }

      it "updates the requested person" do
        person = Person.create! valid_attributes
        put :update, {:id => person.to_param, :person => new_attributes}, valid_session
        person.reload
        new_attributes.each do |attr, value|
          expect(person.send(attr)).to eql(value)
        end
      end

      it "assigns the requested person as @person" do
        person = Person.create! valid_attributes
        put :update, {:id => person.to_param, :person => valid_attributes}, valid_session
        expect(assigns(:person)).to eq(person)
      end

      it "redirects to the person" do
        person = Person.create! valid_attributes
        put :update, {:id => person.to_param, :person => valid_attributes}, valid_session
        expect(response).to redirect_to(person)
      end

      it "redirect to the cropping tool if an image has been attached" do
        person = Person.create! valid_attributes
        put :update, {:id => person.to_param, :person => valid_attributes_with_image}, valid_session
        expect(response).to redirect_to(edit_person_image_path(person))
      end
    end

    describe "with invalid params" do
      it "assigns the person as @person" do
        person = Person.create! valid_attributes
        put :update, {:id => person.to_param, :person => invalid_attributes}, valid_session
        expect(assigns(:person)).to eq(person)
        expect(response).to render_template("edit")
        expect(assigns(:person).assignable_groups).to eql(assigns(:groups))
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested person" do
      person = Person.create! valid_attributes
      expect {
        delete :destroy, {:id => person.to_param}, valid_session
      }.to change(Person, :count).by(-1)
    end

    it "redirects to the people list" do
      person = Person.create! valid_attributes
      delete :destroy, {:id => person.to_param}, valid_session
      expect(response).to redirect_to(people_url)
    end
  end

end

