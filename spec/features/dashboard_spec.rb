require 'spec_helper'

feature 'Visit the dashboard an show the questions for the day' do

  context 'view' do
    scenario "can view the questions tabled for today" do
      visit '/dashboard'
      expect(page).to have_content('Parliamentary Questions of the day')
    end
  end

end
