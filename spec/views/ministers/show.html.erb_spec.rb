require 'spec_helper'

describe "ministers/show" do
  before(:each) do
    @minister = assign(:minister, stub_model(Minister,
      :name => "Name",
      :title => "Title",
      :email => "Email",
      :deleted => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/Title/)
    rendered.should match(/Email/)
    rendered.should match(/false/)
  end
end
