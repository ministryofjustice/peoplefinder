require 'rails_helper'

feature "Managing objectives" do
  before do
    password = generate(:password)
    jobholder = create(:user, name: 'John Doe', password: password)
    create(:agreement, jobholder: jobholder)
    log_in_as jobholder.email, password
  end

  scenario 'Navigating to my objectives' do
    click_link 'Objectives'
    expect(page).to have_css('h1', 'Objectives')
  end

end