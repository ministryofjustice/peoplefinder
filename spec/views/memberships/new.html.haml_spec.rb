require 'rails_helper'

RSpec.describe "memberships/new", :type => :view do
  before(:each) do
    assign(:membership, Membership.new())
  end

  it "renders new membership form" do
    render

    assert_select "form[action=?][method=?]", memberships_path, "post" do
    end
  end
end
