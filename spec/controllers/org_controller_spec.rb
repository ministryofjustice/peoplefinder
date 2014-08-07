require 'rails_helper'

RSpec.describe OrgController, :type => :controller do
  before do
    mock_logged_in_user
  end

  describe "GET show" do
    it "should render JSON of the organisational hierarchy" do
      create(:group, name: "Ministry of Justice")
      get :show

      expected = {
        "name" => "Ministry of Justice",
        "url" => "/groups/ministry-of-justice",
        "children" => []
      }
      expect(JSON.parse(response.body)).to eql(expected)
    end
  end
end
