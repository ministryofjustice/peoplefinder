require 'rails_helper'

feature 'Browse page' do
  include PermittedDomainHelper

  let(:browse_page) { Pages::Browse.new }
  let(:department) { create(:department) }

  before do
    create(:person, :member_of, team: department, leader: true, role: 'Permanent Secretary', given_name: 'Richard', surname: 'Heaton')
  end

  context 'page structure' do
    background do
      mock_readonly_user
      visit '/browse'
    end

    it 'is all there' do
      expect(browse_page).to be_displayed
      expect(browse_page).to have_page_title
      expect(browse_page).to have_about_usage
      expect(browse_page).to have_create_team_link
      expect(browse_page).to have_leader_profile_image
    end

    it 'has page title' do
      expect(browse_page).to have_page_title
      expect(browse_page.page_title).to have_text('Browse Ministry of Justice teams')
    end

    it 'has about usage section' do
      expect(browse_page).to have_about_usage
      expect(browse_page.about_usage).to have_text 'People Finder relies on contributions from everyone to help keep it up-to-date'
    end

    it 'displays perm sec\' image but not name and role' do
      expect(browse_page).to have_leader_profile_image
      expect(browse_page.leader_profile_image[:alt]).to eql 'Current photo of Richard Heaton'
      expect(browse_page).not_to have_text 'Richard Heaton'
    end
  end
end
