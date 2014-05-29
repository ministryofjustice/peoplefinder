require 'spec_helper'

describe "action_officers/new" do
  before(:each) do
    assign(:action_officer, stub_model(ActionOfficer).as_new_record)
  end

  it "renders new action_officer form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", action_officers_path, "post" do
    end
  end
end
