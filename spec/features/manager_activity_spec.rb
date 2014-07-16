require 'rails_helper'

feature 'Manager activity' do
  before do
    log_in_as 'manager@digital.justice.gov.uk'
  end

  scenario 'Viewing an agreement' do
    create(:agreement, jobholder_email: 'jobholder@digital.justice.gov.uk', manager_email: 'manager@digital.justice.gov.uk')

    visit '/'
    click_link('jobholder@digital.justice.gov.uk')

    expect(page).to have_text('Jobholder: jobholder@digital.justice.gov.uk')
    expect(page).to have_field('Manager email', with: 'manager@digital.justice.gov.uk')
  end
end
