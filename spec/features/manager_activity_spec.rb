require 'rails_helper'

feature 'Manager activity' do
  let(:manager) { create(:user, email: 'manager@digital.justice.gov.uk')}

  before do
    log_in_as manager.email
  end

  scenario 'Viewing an agreement' do
    create(:agreement, jobholder_email: 'jobholder@digital.justice.gov.uk', manager_email: manager.email)

    visit '/'
    click_link('jobholder@digital.justice.gov.uk')

    expect(page).to have_text('Jobholder: jobholder@digital.justice.gov.uk')
    expect(page).to have_field('Manager email', with: manager.email)
  end
end
