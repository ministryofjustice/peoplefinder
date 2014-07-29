require 'rails_helper'

feature "Editing objectives" do
  before do
    password = generate(:password)
    staff_member = create(:user, name: 'John Doe', password: password)
    create(:agreement, staff_member: staff_member)
    log_in_as staff_member.email, password
  end

  scenario "Editing objectives as a staff_member", js: true do
    click_button "Objectives"
    within('h1') do
      expect(page.text).to have_text("John Doe’s objectives")
    end

    within('#objectives .fields:nth-child(1)') do
      fill_in "Type", with: "Productivity goal"
      fill_in "Objective", with: "Get to work on time"
      fill_in "Deliverable", with: "A copy of my timesheet"
      fill_in "Measures / Target", with: "An average tardiness of 2.7 minutes"
    end

    click_link 'Add more'

    within('#objectives .fields:nth-child(2)') do
      fill_in "Type", with: "Personal goal"
      fill_in "Objective", with: "Learn to fly"
      fill_in "Deliverable", with: "Sprout wings"
      fill_in "Measures / Target", with: "5m wingspan"
    end

    click_button "Save"

    agreement = Agreement.last

    objectives = agreement.objectives.sort_by(&:created_at)

    expect(objectives[0].objective_type).to match(/Productivity goal/)
    expect(objectives[0].description).to match(/Get to work/)
    expect(objectives[0].deliverables).to match(/copy of my timesheet/)
    expect(objectives[0].measurements).to match(/average tardiness/)

    expect(objectives[1].objective_type).to match(/Personal goal/)
    expect(objectives[1].description).to match(/Learn to fly/)
    expect(objectives[1].deliverables).to match(/Sprout wings/)
    expect(objectives[1].measurements).to match(/5m wingspan/)
  end
end
