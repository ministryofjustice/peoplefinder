require 'rails_helper'

RSpec.describe GroupMembershipsController, :type => :controller do
  before do
    mock_logged_in_user
  end

  let(:group) { create(:group) }
  let(:person) { create(:person) }

  let(:valid_attributes) {
    { person_id: person.id }
  }

  let(:invalid_attributes) {
    { person_id: '' }
  }

  let(:valid_session) { {} }


  describe "GET index" do
    it "assigns all memberships as @memberships" do
      membership = group.memberships.create!(valid_attributes)
      get :index, { group_id: group.id }, valid_session
      expect(assigns(:memberships)).to eq([membership])
    end
  end

  describe "GET show" do
    it "assigns the requested membership as @membership" do
      membership = group.memberships.create!(valid_attributes)
      get :show, { group_id: group.id, id: membership.to_param }, valid_session
      expect(assigns(:membership)).to eq(membership)
    end
  end

  describe "GET new" do
    it "assigns a new membership as @membership" do
      get :new, { group_id: group.id }, valid_session
      expect(assigns(:membership)).to be_a_new(Membership)
      expect(assigns(:membership).group).to eql(group)
    end

    it "should assign only non-members to @candidates" do
      person_a = create(:person)
      person_b = create(:person)
      person_c = create(:person)
      create(:membership, group: group, person: person_a)

      get :new, { group_id: group.id }, valid_session
      expect(assigns(:candidates)).to include(person_b)
      expect(assigns(:candidates)).to include(person_c)
      expect(assigns(:candidates)).not_to include(person_a)
    end
  end

  describe "GET edit" do
    it "assigns the requested membership as @membership" do
      membership = group.memberships.create!(valid_attributes)
      get :edit, { group_id: group.id, id: membership.to_param }, valid_session
      expect(assigns(:membership)).to eq(membership)
    end

    it "should assign non-members and current person to @candidates" do
      person_a = create(:person)
      person_b = create(:person)
      person_c = create(:person)
      create(:membership, group: group, person: person_a)
      membership = create(:membership, group: group, person: person_b)

      get :edit, { id: membership.id, group_id: group.id }, valid_session
      expect(assigns(:candidates)).to include(person_b)
      expect(assigns(:candidates)).to include(person_c)
      expect(assigns(:candidates)).not_to include(person_a)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Membership" do
        expect {
          post :create, { group_id: group.id, membership: valid_attributes}, valid_session
        }.to change(group.memberships, :count).by(1)
      end

      it "assigns a newly created membership as @membership" do
        post :create, { group_id: group.id, membership: valid_attributes}, valid_session
        expect(assigns(:membership)).to be_a(Membership)
        expect(assigns(:membership)).to be_persisted
        expect(assigns(:membership).group).to eql(group)
      end

      it "redirects to the index" do
        post :create, { group_id: group.id, membership: valid_attributes}, valid_session
        expect(response).to redirect_to(group_memberships_path(group))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved membership as @membership" do
        post :create, { group_id: group.id, membership: invalid_attributes}, valid_session
        expect(assigns(:membership)).to be_a_new(Membership)
      end

      it "re-renders the 'new' template" do
        post :create, { group_id: group.id, membership: invalid_attributes}, valid_session
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
        membership = group.memberships.create!(valid_attributes)
        put :update, { group_id: group.id, id: membership.to_param, membership: new_attributes}, valid_session
        membership.reload
        expect(membership.role).to eql(new_attributes[:role])
      end

      it "assigns the requested membership as @membership" do
        membership = group.memberships.create!(valid_attributes)
        put :update, { group_id: group.id, id: membership.to_param, membership: new_attributes}, valid_session
        expect(assigns(:membership)).to eq(membership)
      end

      it "redirects to the index" do
        membership = group.memberships.create!(valid_attributes)
        put :update, { group_id: group.id, id: membership.to_param, membership: new_attributes}, valid_session
        expect(response).to redirect_to(group_memberships_path(group))
      end
    end

    describe "with invalid params" do
      it "assigns the membership as @membership" do
        membership = group.memberships.create!(valid_attributes)
        put :update, { group_id: group.id, id: membership.to_param, membership: invalid_attributes}, valid_session
        expect(assigns(:membership)).to eq(membership)
      end

      it "re-renders the 'edit' template" do
        membership = group.memberships.create!(valid_attributes)
        put :update, { group_id: group.id, id: membership.to_param, membership: invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested membership" do
      membership = group.memberships.create!(valid_attributes)
      expect {
        delete :destroy, { group_id: group.id, id: membership.to_param }, valid_session
      }.to change(group.memberships, :count).by(-1)
    end

    it "redirects to the memberships list" do
      membership = group.memberships.create!(valid_attributes)
      delete :destroy, { group_id: group.id, id: membership.to_param }, valid_session
      expect(response).to redirect_to(group_memberships_path(group))
    end
  end
end
