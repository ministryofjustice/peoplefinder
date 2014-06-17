require 'spec_helper'

describe "progresses/index" do
  before(:each) do
    assign(:progresses, [
      stub_model(Progress,
        :progress_id => 1,
        :progress_label => "Progress Label",
        :progress_order => 2
      ),
      stub_model(Progress,
        :progress_id => 1,
        :progress_label => "Progress Label",
        :progress_order => 2
      )
    ])
  end

  it "renders a list of progresses" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Progress Label".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
