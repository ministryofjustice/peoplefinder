require 'spec_helper'

describe "ministers/edit" do
  before(:each) do
    @minister = assign(:minister, stub_model(Minister,
      :name => "MyString",
      :title => "MyString",
      :email => "MyString",
      :deleted => false
    ))
  end

  it "renders the edit minister form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", minister_path(@minister), "post" do
      assert_select "input#minister_name[name=?]", "minister[name]"
      assert_select "input#minister_title[name=?]", "minister[title]"
      assert_select "input#minister_email[name=?]", "minister[email]"
      assert_select "input#minister_deleted[name=?]", "minister[deleted]"
    end
  end
end
