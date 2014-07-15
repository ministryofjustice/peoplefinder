require 'rails_helper'

feature "Initiating feedback" do
  before do
    log_in_as "jobholder@digital.justice.gov.uk"
  end

  scenario "Initiating feedback as a jobholder" do
    visit "/"
    click_link "Initiate feedback for myself"

    fill_in "Manager email", with: "manager@digital.justice.gov.uk"
    fill_in "Number of staff", with: "There's about 300"
    fill_in "Staff engagement score", with: "I did pretty well for a while"

    within ('.budgetary-responsibilities') do
      fill_in "Type", with: "Capital"
      fill_in "Value", with: "200 quid"
      fill_in "Description", with: "Paid annually"
    end

    click_button "Save"

    manager = User.find_by_email("manager@digital.justice.gov.uk")
    jobholder = User.find_by_email("jobholder@digital.justice.gov.uk")
    agreement = Agreement.last
    budgetary_responsibility = agreement.budgetary_responsibilities.first

    expect(agreement.manager).to eql(manager)
    expect(agreement.jobholder).to eql(jobholder)
    expect(agreement.number_of_staff).to match(/about 300/)
    expect(agreement.staff_engagement_score).to match(/did pretty well/)

    expect(budgetary_responsibility['budget_type']).to match(/Capital/)
    expect(budgetary_responsibility['budget_value']).to match(/200 quid/)
    expect(budgetary_responsibility['description']).to match(/annually/)
  end
end
