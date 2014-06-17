require 'spec_helper'

describe "progresses/edit" do
  before(:each) do
    @progress = assign(:progress, stub_model(Progress,
      :progress_id => 1,
      :progress_label => "MyString",
      :progress_order => 1
    ))
  end

  it "renders the edit progress form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", progress_path(@progress), "post" do
      assert_select "input#progress_progress_id[name=?]", "progress[progress_id]"
      assert_select "input#progress_progress_label[name=?]", "progress[progress_label]"
      assert_select "input#progress_progress_order[name=?]", "progress[progress_order]"
    end
  end
end
