require "rails_helper"

RSpec.describe PeopleController, type: :controller do
  include PermittedDomainHelper

  before do
    mock_logged_in_user
  end

  # This should return the minimal set of attributes required to create a valid
  # Person. As you add validations to Person, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    attributes_for(:person).merge(default_membership_attributes)
  end

  let(:default_membership_attributes) do
    { memberships_attributes: [attributes_for(:membership_default)] }
  end

  let(:invalid_attributes) do
    { surname: "" }
  end

  describe "GET index" do
    it "redirects to the root" do
      get :index
      expect(response).to redirect_to("/")
    end
  end

  describe "GET show" do
    it "assigns the requested person as @person" do
      person = create(:person, valid_attributes)
      get :show, params: { id: person.to_param }
      expect(assigns(:person)).to eq(person)
    end
  end

  describe "GET new" do
    it "assigns a new person as @person" do
      get :new
      expect(assigns(:person)).to be_a_new(Person)
    end

    it "builds a membership object" do
      get :new
      expect(assigns(:person).memberships.length).to be(1)
    end
  end

  describe "GET edit" do
    let(:person) { create(:person, valid_attributes) }

    it "assigns the requested person as @person" do
      get :edit, params: { id: person.to_param }
      expect(assigns(:person)).to eq(person)
    end

    context "when building memberships" do
      it "builds a membership if there isn't one already" do
        person.memberships.destroy_all
        expect(person.memberships.count).to eq 0
        get :edit, params: { id: person.to_param }
        expect(assigns(:person).memberships.length).to be(1)
      end

      it "does not build a membership when there is one already" do
        expect(person.memberships.count).to eq 1
        get :edit, params: { id: person.to_param }
        expect(assigns(:person).memberships.length).to be(1)
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Person" do
        expect {
          post :create, params: { person: valid_attributes }
        }.to change(Person, :count).by(1)
      end

      it "assigns a newly created person as @person" do
        post :create, params: { person: valid_attributes }
        expect(assigns(:person)).to be_a(Person)
        expect(assigns(:person)).to be_persisted
      end

      it "redirects to the created person" do
        attributes = valid_attributes
        email = attributes[:email]
        post :create, params: { person: attributes }
        expect(response).to redirect_to(Person.find_by_email(email))
      end
    end

    describe "with invalid params" do
      render_views

      before do
        post :create, params: { person: invalid_attributes }
      end

      it "assigns a newly created but unsaved person as @person" do
        expect(assigns(:person)).to be_a_new(Person)
      end

      it "re-renders the new template" do
        expect(response).to render_template("new")
      end

      it "shows an error message" do
        expect(response.body).to match(/Last name is required/)
      end
    end

    describe "with duplicate name" do
      it "renders the confirm template" do
        create(:person, given_name: "Bo", surname: "Diddley")
        duplicate_person_params = valid_attributes.merge(given_name: "Bo", surname: "Diddley", email: "bo.diddley@digital.justice.gov.uk")
        post :create, params: { person: duplicate_person_params }
        expect(response).to render_template("confirm")
      end
    end

    describe "when trying to create a super admin" do
      subject(:person) { assigns(:person) }

      before do
        post :create, params: { person: attributes_for(:super_admin).merge(default_membership_attributes) }
      end

      it "creates the person" do
        expect(person).to be_persisted
      end

      it "creates person, but not as super admin" do
        expect(person).not_to be_super_admin
      end
    end
  end

  describe "PUT update myself" do
    let(:person) { current_user }

    before do
      put :update, params: { id: person.to_param, person: new_attributes, commit: "Save" }
    end

    describe "with valid params" do
      let(:new_attributes) do
        attributes_for(:person).merge(works_tuesday: false)
      end

      it "updates the person" do
        person.reload
        new_attributes.each do |key, value|
          expect(person.__send__(key)).to eql value
        end
      end

      it "shows no notice about informing the person" do
        expect(flash[:notice]).not_to match(/We have let/)
        expect(flash[:notice]).to match(/Updated your profile/)
      end
    end

    describe "when trying to grant super admin" do
      let(:new_attributes) do
        attributes_for(:person).merge(super_admin: true)
      end

      it "does not grant super admin privileges" do
        person.reload
        expect(person).not_to be_super_admin
      end
    end
  end

  describe "PUT update a third party" do
    let(:person) { create(:person, valid_attributes) }

    describe "with valid params" do
      let(:new_attributes) do
        attributes_for(:person).merge(
          works_monday: true,
          works_tuesday: false,
          works_saturday: true,
          works_sunday: false,
        )
      end

      before do
        put :update, params: { id: person.to_param, person: new_attributes, commit: "Save" }
      end

      it "updates the requested person apart from e-mail" do
        person.reload
        new_attributes.each do |attr, value|
          if attr != :email
            expect(person.send(attr)).to eql(value)
          end
        end
      end

      it "allows update of e-mail too" do
        person.reload
        expect(person.email).to eql(new_attributes[:email])
      end

      it "assigns the requested person as @person" do
        expect(assigns(:person)).to eq(person)
      end

      it "redirects to the person" do
        expect(response).to redirect_to(person)
      end

      it "shows a notice about informing the person" do
        expect(flash[:notice]).to match(/We have let/)
      end
    end

    describe "with invalid params" do
      before do
        put :update, params: { id: person.to_param, person: invalid_attributes }
      end

      it "assigns the person as @person" do
        expect(assigns(:person)).to eq(person)
      end

      it "re-renders the edit template" do
        expect(response).to render_template("edit")
      end
    end

    describe "with duplicate name" do
      let(:person) { create(:person, given_name: "Bobbie", surname: "Browne") }

      before do
        create(:person, given_name: "Bo", surname: "Diddley")
      end

      it "when fundamental info amended it renders the confirm template" do
        put :update, params: { id: person.to_param, person: { given_name: "Bo", surname: "Diddley" } }
        expect(response).to render_template :confirm
      end

      it "when fundamental info NOT altered it redirects to profile page" do
        put :update, params: { id: person.to_param, person: { current_project: "whatevers" } }
        expect(response).to redirect_to person_path(person)
      end
    end

    describe "when trying to grant super admin privileges" do
      let(:attributes_with_super_admin) do
        attributes_for(:super_admin)
      end

      before do
        put :update, params: { id: person.to_param, person: attributes_with_super_admin }
      end

      it "does not grant super admin privileges" do
        person.reload
        expect(person).not_to be_super_admin
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested person" do
      person = create(:person, valid_attributes)
      expect {
        delete :destroy, params: { id: person.to_param }
      }.to change(Person, :count).by(-1)
    end

    context "when person member of teams" do
      it "redirects to first team page" do
        person = create(:person, valid_attributes)
        groups = create_list(:group, 2)
        groups.each do |group|
          create :membership, person:, group:
        end

        delete :destroy, params: { id: person.to_param }
        expect(response).to redirect_to(group_path(groups.first))
      end
    end

    it "sets a flash message" do
      person = create(:person, valid_attributes)
      delete :destroy, params: { id: person.to_param }
      expect(flash[:notice]).to include("Deleted #{person}’s profile")
    end
  end

  describe "GET add_membership" do
    context "with a new person" do
      it "renders add_membership template" do
        get :add_membership
        expect(response).to render_template("add_membership")
      end
    end

    context "with an existing person" do
      let(:person) { create(:person) }

      it "renders add_membership template" do
        get :add_membership, params: { id: person }
        expect(response).to render_template("add_membership")
      end
    end
  end

  context "when action routing" do
    context "with create" do
      context "when save button pressed" do
        it "updates and shows the edit person page" do
          post :create, params: { person: valid_attributes.merge(given_name: "Francis", surname: "Drake", email: "francis.drake@digital.justice.gov.uk") }
          person = Person.friendly.find("francis-drake")
          expect(response).to redirect_to person_path(person)
        end
      end

      context "with duplicates in database" do
        before do
          create :person, given_name: "Francis", surname: "Drake", email: "fd@digital.justice.gov.uk"
        end

        context "when save button presssed with duplicate person in database" do
          it "displays duplicate confirmation page" do
            post :create, params: { person: valid_attributes.merge(given_name: "Francis", surname: "Drake", email: "francis.drake@digital.justice.gov.uk") }
            expect(response).to render_template(:confirm)
          end
        end

        context "when pressing confirm on duplicate confirmation page" do
          it "updates and shows the person edit page" do
            post :create, params: { person: valid_attributes.merge(given_name: "Francis", surname: "Drake", email: "francis.drake@digital.justice.gov.uk"), continue_from_duplication: "1" }
            person = Person.friendly.find("francis-drake")
            expect(response).to redirect_to person_path(person)
          end
        end
      end
    end
  end
end
