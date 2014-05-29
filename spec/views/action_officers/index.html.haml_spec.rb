require 'spec_helper'

describe "action_officers/index" do
  before(:each) do
    assign(:action_officers, [
      stub_model(ActionOfficer),
      stub_model(ActionOfficer)
    ])
  end

  it "renders a list of action_officers" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
