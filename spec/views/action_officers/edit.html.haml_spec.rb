require 'spec_helper'

describe "action_officers/edit" do
  before(:each) do
    @action_officer = assign(:action_officer, stub_model(ActionOfficer))
  end

  it "renders the edit action_officer form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", action_officer_path(@action_officer), "post" do
    end
  end
end
