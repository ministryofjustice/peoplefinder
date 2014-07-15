require 'rails_helper'

feature "Initiating feedback" do
  before do
    log_in_as "example.user@digital.justice.gov.uk"
  end

  scenario "Initiating feedback as a jobholder" do
    visit "/"
    click_link "Initiate feedback for myself"

    expect(page).to have_text('Personal details')
  end
end
