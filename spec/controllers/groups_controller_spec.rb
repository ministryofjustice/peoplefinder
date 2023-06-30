require "rails_helper"

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe GroupsController, type: :controller do
  include PermittedDomainHelper

  before do
    mock_logged_in_user
    Group.destroy_all
  end

  # This should return the minimal set of attributes required to create a valid
  # Group. As you add validations to Group, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    attributes_for(:group)
  end

  let(:invalid_attributes) do
    { name: "" }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # GroupsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let(:person) { create(:person) }

  describe "GET index" do
    subject { get :index, params: {}, flash: valid_session }

    it "without any groups, it redirects to the new group page" do
      expect(subject).to redirect_to(new_group_path)
    end

    it "with a department, it redirects to the departmental page" do
      department = create(:department)
      expect(subject).to redirect_to(group_path(department))
    end

    it "with a department and a team, it still redirects to the departmental page" do
      department = create(:department)
      create(:group, parent: department)
      expect(subject).to redirect_to(group_path(department))
    end
  end

  describe "GET show" do
    it "assigns the requested group as @group" do
      group = create(:group, valid_attributes)
      get :show, params: { id: group.to_param }, flash: valid_session
      expect(assigns(:group)).to eq(group)
    end
  end

  describe "GET all_people" do
    subject { get :all_people, params: { id: group.to_param, page: 2 }, flash: valid_session }

    let(:group) { create(:group, valid_attributes) }
    let!(:people) { instance_double(Person.const_get(:ActiveRecord_Relation)) }

    it "assigns @group to a Group instance" do
      subject
      expect(assigns(:group)).to be_a(Group)
    end

    it "assigns @people_in_subtree to a Person AR relation" do
      subject
      expect(assigns(:people_in_subtree)).to be_a(Person.const_get(:ActiveRecord_Relation))
    end

    it "sends all_people message to instance of group and paginates people results to 500 (to avoid server timeouts)" do
      expect_any_instance_of(Group).to receive(:all_people).and_return people
      expect(people).to receive(:paginate).with(page: "2", per_page: 500).and_return people
      subject
    end
  end

  describe "GET new" do
    it "assigns a new group as @group" do
      get :new, params: {}, flash: valid_session
      expect(assigns(:group)).to be_a_new(Group)
    end

    it "assigns a membership object" do
      get :new, params: {}, flash: valid_session
      expect(assigns(:group).memberships.length).to be(1)
    end
  end

  describe "GET edit" do
    let(:group) { create(:group, valid_attributes) }

    it "assigns the requested group as @group" do
      get :edit, params: { id: group.to_param }, flash: valid_session
      expect(assigns(:group)).to eql(group)
    end
  end

  describe "POST create" do
    context "when no top level group exists" do
      describe "with valid params" do
        it "creates a new Group" do
          expect {
            post :create, params: { group: valid_attributes }, flash: valid_session
          }.to change(Group, :count).by(1)
        end

        it "assigns a newly created group as @group" do
          post :create, params: { group: valid_attributes }, flash: valid_session
          expect(assigns(:group)).to be_a(Group)
          expect(assigns(:group)).to be_persisted
        end

        it "redirects to the created group" do
          group_attrs = valid_attributes
          post :create, params: { group: group_attrs }, flash: valid_session
          expect(response).to redirect_to(Group.find_by(name: group_attrs[:name]))
        end
      end
    end

    context "when top level groups exists" do
      describe "with valid params" do
        before do
          department
        end

        let(:department) { create(:department) }
        let(:valid_attributes) { attributes_for(:group).merge(parent_id: department.id) }

        it "creates a new Group" do
          expect {
            post :create, params: { group: valid_attributes }, flash: valid_session
          }.to change(Group, :count).by(1)
        end

        it "assigns a newly created group as @group" do
          post :create, params: { group: valid_attributes }, flash: valid_session
          expect(assigns(:group)).to be_a(Group)
          expect(assigns(:group)).to be_persisted
        end

        it "redirects to the created group" do
          group_attrs = valid_attributes
          post :create, params: { group: group_attrs }, flash: valid_session
          expect(response).to redirect_to(Group.find_by(name: group_attrs[:name]))
        end
      end
    end

    describe "with valid params including parent_id and format json" do
      it "returns group as json" do
        parent_group = create(:group, attributes_for(:group))

        attributes = valid_attributes.merge(parent_id: parent_group.id)
        post :create, params: { group: attributes, format: :json }, flash: valid_session
        expect(response.code).to eq "201"

        group = Group.find_by_name(attributes[:name])

        result = JSON.parse(response.body)
        expect(result["id"]).to eq group.id
        expect(result["name"]).to eq group.name
        expect(result["slug"]).to eq group.slug
        expect(result["parent_id"]).to eq group.parent_id
      end
    end

    describe "with valid params excluding parent_id and format json" do
      it "returns errors as json" do
        create(:department)

        attributes = valid_attributes.merge(parent_id: nil)
        post :create, params: { group: attributes, format: :json }, flash: valid_session

        expect(response.code).to eq "422"
        expect(response.body).to eq '{"parent_id":["is required"]}'
      end
    end

    describe "with invalid params" do
      render_views

      before do
        post :create, params: { group: invalid_attributes }, flash: valid_session
      end

      it "assigns a newly created but unsaved group as @group" do
        expect(assigns(:group)).to be_a_new(Group)
      end

      it "re-renders the new template" do
        expect(response).to render_template("new")
      end

      it "shows an error message" do
        expect(response.body).to have_selector(".error-summary", text: /Team name is required/)
      end
    end

    describe "with invalid params including parent_id and format json" do
      before do
        post :create, params: { group: invalid_attributes, format: :json }, flash: valid_session
      end

      it "returns errors as json" do
        expect(response.code).to eq "422"
        expect(response.body).to eq '{"name":["is required"]}'
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      let(:new_attributes) do
        attributes_for(:group)
      end

      it "updates the requested group" do
        group = create(:group, valid_attributes)
        put :update, params: { id: group.to_param, group: new_attributes }, flash: valid_session
        group.reload
        expect(group.name).to eql(new_attributes[:name])
      end

      it "assigns the requested group as @group" do
        group = create(:group, valid_attributes)
        put :update, params: { id: group.to_param, group: valid_attributes }, flash: valid_session
        expect(assigns(:group)).to eq(group)
      end

      it "redirects to the group" do
        group = create(:group, valid_attributes)
        put :update, params: { id: group.to_param, group: valid_attributes }, flash: valid_session
        expect(response).to redirect_to(group)
      end
    end

    describe "with invalid params" do
      render_views

      let(:group) { create(:group, valid_attributes) }

      before do
        put :update, params: { id: group.to_param, group: invalid_attributes }, flash: valid_session
      end

      it "assigns the group as @group" do
        expect(assigns(:group)).to eq(group)
      end

      it "re-renders the edit template" do
        expect(response).to render_template("edit")
      end

      it "shows an error message" do
        expect(response.body).to have_selector(".error-summary", text: /Team name is required/)
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested group" do
      group = create(:group, valid_attributes)
      expect {
        delete :destroy, params: { id: group.to_param }, flash: valid_session
      }.to change(Group, :count).by(-1)
    end

    it "redirects to the parent group" do
      parent = create(:group, parent: nil)
      group = create(:group, parent:)
      delete :destroy, params: { id: group.to_param }, flash: valid_session
      expect(response).to redirect_to(parent)
    end
  end
end
