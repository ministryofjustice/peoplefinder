require 'rails_helper'

RSpec.describe "memberships/index", :type => :view do
  before(:each) do
    assign(:memberships, [
      Membership.create!(),
      Membership.create!()
    ])
  end

  it "renders a list of memberships" do
    render
  end
end
