require 'rails_helper'

feature "Edititing responsibilities" do
  before do
    log_in_as "jobholder@digital.justice.gov.uk"
    create(:agreement, jobholder: User.where(email: "jobholder@digital.justice.gov.uk").first)
  end

  scenario "Edititing responsibilities as a jobholder" do
    visit "/"
    click_button "Continue"

    fill_in "Number of staff", with: "There's about 300"
    fill_in "Staff engagement score", with: "I did pretty well for a while"

    within ('.budgetary-responsibilities') do
      fill_in "Type", with: "Capital"
      fill_in "Value", with: "200 quid"
      fill_in "Description", with: "Paid annually"
    end

    within ('.objectives') do
      fill_in "Type", with: "Productivity goal"
      fill_in "Objective", with: "Get to work on time"
      fill_in "Deliverable", with: "A copy of my timesheet"
      fill_in "Measures / Target", with: "An average tardiness of 2.7 minutes"
    end

    click_button "Save"

    agreement = Agreement.last
    budgetary_responsibility = agreement.budgetary_responsibilities.first
    objectives = agreement.objectives.first

    expect(agreement.number_of_staff).to match(/about 300/)
    expect(agreement.staff_engagement_score).to match(/did pretty well/)

    expect(budgetary_responsibility['budget_type']).to match(/Capital/)
    expect(budgetary_responsibility['budget_value']).to match(/200 quid/)
    expect(budgetary_responsibility['description']).to match(/annually/)

    expect(objectives['objective_type']).to match(/Productivity goal/)
    expect(objectives['description']).to match(/Get to work/)
    expect(objectives['deliverable']).to match(/copy of my timesheet/)
    expect(objectives['measures']).to match(/average tardiness/)
  end
end
