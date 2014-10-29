require 'rails_helper'

feature "Communities" do
  before do
    omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario 'Creating a person in a community' do
    group = create(:group, name: 'Digital Justice')
    group = create(:community, name: 'Advanced cybernetics')
    # javascript_log_in

    visit new_person_path
    fill_in 'First name', with: 'Jane'
    fill_in 'Surname', with: 'Doe'
    select('Advanced cybernetics', from: 'Community')
    click_button "Create"

    save_and_open_page
    expect(page).to have_text("Jane Doe")
    expect(page).to have_text("Advanced cybernetics")

  end
end
