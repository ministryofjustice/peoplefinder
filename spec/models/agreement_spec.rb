require 'rails_helper'

RSpec.describe Agreement, :type => :model do
  let(:email) { "example.user@digital.justice.gov.uk" }

  it "should assign an existing user via manager_email" do
    user = create(:user)
    agreement = create(:agreement, manager_email: user.email)
    agreement.reload
    expect(agreement.manager).to eql(user)
  end

  it "should create a new user and assign as manager" do
    agreement = create(:agreement, manager_email: email)
    agreement.reload
    expect(agreement.manager.email).to eql(email)
  end

  it "should assign an existing user via jobholder_email" do
    user = create(:user)
    agreement = create(:agreement, jobholder_email: user.email)
    agreement.reload
    expect(agreement.jobholder).to eql(user)
  end

  it "should create a new user and assign as jobholder" do
    email = "example.user@digital.justice.gov.uk"
    agreement = create(:agreement, jobholder_email: email)
    agreement.reload
    expect(agreement.jobholder.email).to eql(email)
  end
end
