require 'rails_helper'

RSpec.describe "memberships/edit", :type => :view do
  before(:each) do
    @membership = assign(:membership, Membership.create!())
  end

  it "renders the edit membership form" do
    render

    assert_select "form[action=?][method=?]", membership_path(@membership), "post" do
    end
  end
end
