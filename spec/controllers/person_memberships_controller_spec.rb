require 'rails_helper'

RSpec.describe PersonMembershipsController, :type => :controller do
  before do
    mock_logged_in_user
  end

  let(:group) { create(:group) }
  let(:person) { create(:person) }

  let(:valid_attributes) {
    { group_id: group.id }
  }

  let(:invalid_attributes) {
    { group_id: '' }
  }

  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all memberships as @memberships" do
      membership = person.memberships.create!(valid_attributes)
      get :index, { person_id: person.id }, valid_session
      expect(assigns(:memberships)).to eq([membership])
    end
  end

  describe "GET show" do
    it "assigns the requested membership as @membership" do
      membership = person.memberships.create!(valid_attributes)
      get :show, { person_id: person.id, id: membership.to_param }, valid_session
      expect(assigns(:membership)).to eq(membership)
    end
  end

  describe "GET new" do
    it "assigns a new membership as @membership" do
      get :new, { person_id: person.id }, valid_session
      expect(assigns(:membership)).to be_a_new(Membership)
      expect(assigns(:membership).person).to eql(person)
    end

    it "should assign only groups that the person is not a member of to @candidates" do
      person = create(:person)
      group_a = create(:group)
      group_b = create(:group)
      group_c = create(:group)
      create(:membership, person: person, group: group_a)

      get :new, { person_id: person.id }, valid_session
      expect(assigns(:candidates)).to include(group_b)
      expect(assigns(:candidates)).to include(group_c)
      expect(assigns(:candidates)).not_to include(group_a)
    end
  end

  describe "GET edit" do
    it "assigns the requested membership as @membership" do
      membership = person.memberships.create!(valid_attributes)
      get :edit, { person_id: person.id, id: membership.to_param }, valid_session
      expect(assigns(:membership)).to eq(membership)
    end

    it "should assign only groups that the person is not a member of and the current group to @candidates" do
      person = create(:person)
      group_a = create(:group, name: 'A')
      group_b = create(:group, name: 'B')
      group_c = create(:group, name: 'C')
      create(:membership, person: person, group: group_a)
      membership = create(:membership, person: person, group: group_b)

      get :edit, { id: membership.id, person_id: person.id }, valid_session
      expect(assigns(:candidates)).to include(group_b)
      expect(assigns(:candidates)).to include(group_c)
      expect(assigns(:candidates)).not_to include(group_a)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Membership" do
        expect {
          post :create, { person_id: person.id, membership: valid_attributes}, valid_session
        }.to change(person.memberships, :count).by(1)
      end

      it "assigns a newly created membership as @membership" do
        post :create, { person_id: person.id, membership: valid_attributes}, valid_session
        expect(assigns(:membership)).to be_a(Membership)
        expect(assigns(:membership)).to be_persisted
        expect(assigns(:membership).person).to eql(person)
      end

      it "redirects to the index" do
        post :create, { person_id: person.id, membership: valid_attributes}, valid_session
        expect(response).to redirect_to(person_memberships_path(person))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved membership as @membership" do
        post :create, { person_id: person.id, membership: invalid_attributes}, valid_session
        expect(assigns(:membership)).to be_a_new(Membership)
      end

      it "re-renders the 'new' template" do
        post :create, { person_id: person.id, membership: invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      let(:new_attributes) {
        { role: "King" }
      }

      it "updates the requested membership" do
        membership = person.memberships.create!(valid_attributes)
        put :update, { person_id: person.id, id: membership.to_param, membership: new_attributes}, valid_session
        membership.reload
        expect(membership.role).to eql(new_attributes[:role])
      end

      it "assigns the requested membership as @membership" do
        membership = person.memberships.create!(valid_attributes)
        put :update, { person_id: person.id, id: membership.to_param, membership: new_attributes}, valid_session
        expect(assigns(:membership)).to eq(membership)
      end

      it "redirects to the index" do
        membership = person.memberships.create!(valid_attributes)
        put :update, { person_id: person.id, id: membership.to_param, membership: new_attributes}, valid_session
        expect(response).to redirect_to(person_memberships_path(person))
      end
    end

    describe "with invalid params" do
      it "assigns the membership as @membership" do
        membership = person.memberships.create!(valid_attributes)
        put :update, { person_id: person.id, id: membership.to_param, membership: invalid_attributes}, valid_session
        expect(assigns(:membership)).to eq(membership)
      end

      it "re-renders the 'edit' template" do
        membership = person.memberships.create!(valid_attributes)
        put :update, { person_id: person.id, id: membership.to_param, membership: invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested membership" do
      membership = person.memberships.create!(valid_attributes)
      expect {
        delete :destroy, { person_id: person.id, id: membership.to_param }, valid_session
      }.to change(person.memberships, :count).by(-1)
    end

    it "redirects to the memberships list" do
      membership = person.memberships.create!(valid_attributes)
      delete :destroy, { person_id: person.id, id: membership.to_param }, valid_session
      expect(response).to redirect_to(person_memberships_path(person))
    end
  end
end
