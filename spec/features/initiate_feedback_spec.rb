require 'rails_helper'

feature "Initiating feedback" do
  before do
    log_in_as "example.user@digital.justice.gov.uk"
  end

  scenario "Initiating feedback as a jobholder" do
    visit "/"
    click_link "Initiate feedback for myself"
    fill_in "Manager email", with: "manager@digital.justice.gov.uk"
    click_button "Save"

    manager = User.find_by_email("manager@digital.justice.gov.uk")
    jobholder = User.find_by_email("example.user@digital.justice.gov.uk")
    expect(Agreement.last.manager).to eql(manager)
    expect(Agreement.last.jobholder).to eql(jobholder)
  end

  scenario "Initiating feedback as a manager" do
    visit "/"
    click_link "Initiate feedback as a manager"
    fill_in "Jobholder email", with: "jobholder@digital.justice.gov.uk"
    click_button "Save"

    jobholder = User.find_by_email("jobholder@digital.justice.gov.uk")
    manager = User.find_by_email("example.user@digital.justice.gov.uk")
    expect(Agreement.last.manager).to eql(manager)
    expect(Agreement.last.jobholder).to eql(jobholder)
  end
end
