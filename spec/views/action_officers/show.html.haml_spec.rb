require 'spec_helper'

describe "action_officers/show" do
  before(:each) do
    @action_officer = assign(:action_officer, stub_model(ActionOfficer))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
