require 'spec_helper'

describe "action_officers/edit" do
  before(:each) do
    @action_officer = assign(:action_officer, stub_model(ActionOfficer,
      :name => "MyString",
      :email => "MyString"
    ))
  end

  it "renders the edit action_officer form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", action_officer_path(@action_officer), "post" do
      assert_select "input#action_officer_name[name=?]", "action_officer[name]"
      assert_select "input#action_officer_email[name=?]", "action_officer[email]"
    end
  end
end
