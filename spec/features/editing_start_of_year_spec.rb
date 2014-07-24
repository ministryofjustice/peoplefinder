require 'rails_helper'

feature "Editing start of year agreement" do
  before do
    password = generate(:password)
    jobholder = create(:user, name: 'John Doe', password: password)
    create(:agreement, jobholder: jobholder)
    log_in_as jobholder.email, password
  end

  scenario "Edititing responsibilities as a jobholder", js: true do
    click_button "Continue"
    within('h1') do
      expect(page.text).to have_text("John Doe’s responsibilities")
    end

    fill_in "Number of staff", with: "There's about 300"
    fill_in "Staff engagement score", with: "I did pretty well for a while"

    within('.budgetary-responsibility:nth-child(1)') do
      fill_in "Type", with: "Capital"
      fill_in "Value", with: "200 quid"
      fill_in "Description", with: "Paid annually"
    end

    within('#budgetary-responsibilities') do
      click_link("Add another")
    end

    within('.budgetary-responsibility:nth-child(2)') do
      fill_in "Type", with: "Imaginary"
      fill_in "Value", with: "37 Dunning-Krugerrands"
      fill_in "Description", with: "Simian"
    end

    within('#objectives .cloneable-item:nth-child(1)') do
      fill_in "Type", with: "Productivity goal"
      fill_in "Objective", with: "Get to work on time"
      fill_in "Deliverable", with: "A copy of my timesheet"
      fill_in "Measures / Target", with: "An average tardiness of 2.7 minutes"
    end

    # within('#objectives') do
    #   click_link("Add another")
    # end
    #
    # within('#objectives .cloneable-item:nth-child(2)') do
    #   fill_in "Type", with: "Personal goal"
    #   fill_in "Objective", with: "Learn to fly"
    #   fill_in "Deliverable", with: "Sprout wings"
    #   fill_in "Measures / Target", with: "5m wingspan"
    # end

    click_button "Save"

    agreement = Agreement.last

    expect(agreement.number_of_staff).to match(/about 300/)
    expect(agreement.staff_engagement_score).to match(/did pretty well/)

    budgetary_responsibility = agreement.budgetary_responsibilities[0]
    expect(budgetary_responsibility['budget_type']).to match(/Capital/)
    expect(budgetary_responsibility['budget_value']).to match(/200 quid/)
    expect(budgetary_responsibility['description']).to match(/annually/)

    budgetary_responsibility = agreement.budgetary_responsibilities[1]
    expect(budgetary_responsibility['budget_type']).to match(/Imaginary/)
    expect(budgetary_responsibility['budget_value']).to match(/37 Dunning-Krugerrands/)
    expect(budgetary_responsibility['description']).to match(/Simian/)

    objectives = agreement.objectives.first



    expect(objectives.objective_type).to match(/Productivity goal/)
    expect(objectives.description).to match(/Get to work/)
    expect(objectives.deliverables).to match(/copy of my timesheet/)
    expect(objectives.measurements).to match(/average tardiness/)

  end

  scenario 'Add and remove budgetary responsibilities to an agreement', js: true do
    click_button "Continue"

    within('#budgetary-responsibilities') do
      expect(page).not_to have_link('Remove last row')

      2.times do
        click_link "Add another"
      end
      expect(page).to have_css('.budgetary-responsibility', count: 3)

      click_link "Remove last row"
      expect(page).to have_css('.budgetary-responsibility', count: 2)

      click_link "Remove last row"
      expect(page).to have_css('.budgetary-responsibility', count: 1)
      expect(page).not_to have_link('Remove last row')
    end
  end
end
