require 'rails_helper'

feature "Editing responsibilities" do
  before do
    password = generate(:password)
    staff_member = create(:user, name: 'John Doe', password: password)
    create(:agreement, staff_member: staff_member)
    log_in_as staff_member.email, password
  end

  scenario "Editing responsibilities as a staff_member", js: true do
    click_button "Responsibilities"
    within('h1') do
      expect(page.text).to have_text("John Doe’s responsibilities")
    end

    fill_in "Number of staff", with: "There's about 300"
    fill_in "Staff engagement score", with: "I did pretty well for a while"

    within('#budgetary-responsibilities .fields:nth-child(1)') do
      fill_in "Type", with: "Capital"
      fill_in "Value", with: "200"
      fill_in "Description", with: "Paid annually"
    end

    click_link 'Add more'

    within('#budgetary-responsibilities .fields:nth-child(2)') do
      fill_in "Type", with: "Imaginary"
      fill_in "Value", with: "1"
      fill_in "Description", with: "Stuff"
    end

    click_button "Save"

    agreement = Agreement.last

    expect(agreement.number_of_staff).to match(/about 300/)
    expect(agreement.staff_engagement_score).to match(/did pretty well/)

    brs = agreement.budgetary_responsibilities.sort_by(&:created_at)

    expect(brs[0].budget_type).to match(/Capital/)
    expect(brs[0].value).to eql(200)
    expect(brs[0].description).to match(/annually/)

    expect(brs[1].budget_type).to match(/Imaginary/)
    expect(brs[1].value).to eql(1)
    expect(brs[1].description).to match(/Stuff/)
  end
end
