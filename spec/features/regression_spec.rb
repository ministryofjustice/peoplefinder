require "rails_helper"

describe "Regression" do
  include PermittedDomainHelper

  let(:login_page) { Pages::Login.new }

  before do
    token_log_in_as "test.user@digital.justice.gov.uk"
  end

  it "Gracefully handle a session when the logged in person deletes their profile" do
    visit person_path(Person.last)
    click_delete_profile
    expect(login_page).to be_displayed
  end
end
