require 'rails_helper'

RSpec.describe GroupMembershipsController, :type => :controller do
  before do
    mock_logged_in_user
  end

  let(:valid_session) { {} }

  describe "GET new" do
    it "should assign only non-members to @candidates" do
      group = create(:group)
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
    it "should assign non-members and current person to @candidates" do
      group = create(:group)
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
end
