require 'spec_helper'

describe "action_officers/show" do
  before(:each) do
    @action_officer = assign(:action_officer, stub_model(ActionOfficer,
      :name => "Name",
      :email => "Email"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/Email/)
  end
end
