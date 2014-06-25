require 'rails_helper'

RSpec.describe PersonMembershipsController, :type => :controller do
  before do
    mock_logged_in_user
  end

  let(:valid_session) { {} }

  describe "GET new" do
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
end
