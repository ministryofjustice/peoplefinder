require 'spec_helper'

describe "ministers/index" do
  before(:each) do
    assign(:ministers, [
      stub_model(Minister,
        :name => "Name",
        :title => "Title",
        :email => "Email",
        :deleted => false
      ),
      stub_model(Minister,
        :name => "Name",
        :title => "Title",
        :email => "Email",
        :deleted => false
      )
    ])
  end

  it "renders a list of ministers" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "Email".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
