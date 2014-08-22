require 'rails_helper'

RSpec.describe OrgController, type: :controller do
  before do
    mock_logged_in_user
  end

  describe "GET show" do
    it "renders JSON of the organisational hierarchy" do
      group = create(:department)
      get :show

      expected = {
        "id" => group.id,
        "name" => "Ministry of Justice",
        "url" => "/teams/ministry-of-justice",
        "children" => []
      }
      expect(JSON.parse(response.body)).to eql(expected)
    end
  end
end
