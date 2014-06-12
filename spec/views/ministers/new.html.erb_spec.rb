require 'spec_helper'

describe "ministers/new" do
  before(:each) do
    assign(:minister, stub_model(Minister,
      :name => "MyString",
      :title => "MyString",
      :email => "MyString",
      :deleted => false
    ).as_new_record)
  end

  it "renders new minister form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", ministers_path, "post" do
      assert_select "input#minister_name[name=?]", "minister[name]"
      assert_select "input#minister_title[name=?]", "minister[title]"
      assert_select "input#minister_email[name=?]", "minister[email]"
      assert_select "input#minister_deleted[name=?]", "minister[deleted]"
    end
  end
end
