require 'rails_helper'

feature "Editing start of year agreement" do
  before do
    password = generate(:password)
    jobholder = create(:user, name: 'John Doe', password: password)
    create(:agreement, jobholder: jobholder)
    log_in_as jobholder.email, password
  end

  scenario "Editing responsibilities as a jobholder", js: true do
    click_button "Responsibilities"
    within('h1') do
      expect(page.text).to have_text("John Doe’s responsibilities")
    end

    fill_in "Number of staff", with: "There's about 300"
    fill_in "Staff engagement score", with: "I did pretty well for a while"

    within('.budgetary-responsibility:nth-child(1)') do
      fill_in "Type", with: "Capital"
      fill_in "Value", with: "200"
      fill_in "Description", with: "Paid annually"
    end

    click_button "Save"

    agreement = Agreement.last

    expect(agreement.number_of_staff).to match(/about 300/)
    expect(agreement.staff_engagement_score).to match(/did pretty well/)

    budgetary_responsibility = agreement.budgetary_responsibilities[0]
    expect(budgetary_responsibility.budget_type).to match(/Capital/)
    expect(budgetary_responsibility.value).to eql(200)
    expect(budgetary_responsibility.description).to match(/annually/)
  end

  scenario "Edititing objectives as a jobholder", js: true do
    click_button "Objectives"
    within('h1') do
      expect(page.text).to have_text("John Doe’s objectives")
    end

    within('.cloneable-item:nth-child(1)') do
      fill_in "Type", with: "Productivity goal"
      fill_in "Objective", with: "Get to work on time"
      fill_in "Deliverable", with: "A copy of my timesheet"
      fill_in "Measures / Target", with: "An average tardiness of 2.7 minutes"
    end

    click_button "Save"

    agreement = Agreement.last

    objectives = agreement.objectives.first
    expect(objectives.objective_type).to match(/Productivity goal/)
    expect(objectives.description).to match(/Get to work/)
    expect(objectives.deliverables).to match(/copy of my timesheet/)
    expect(objectives.measurements).to match(/average tardiness/)
  end
end
