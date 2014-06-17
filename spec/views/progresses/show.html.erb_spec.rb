require 'spec_helper'

describe "progresses/show" do
  before(:each) do
    @progress = assign(:progress, stub_model(Progress,
      :progress_id => 1,
      :progress_label => "Progress Label",
      :progress_order => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/Progress Label/)
    rendered.should match(/2/)
  end
end
