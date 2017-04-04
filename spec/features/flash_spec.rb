require 'rails_helper'

feature 'Flash messages feature' do
  include PermittedDomainHelper

  RSpec::Matchers.define :appear_before do |later_content|
    match do |earlier_content|
      page.body.index(earlier_content) < page.body.index(later_content)
    end
  end

  describe 'layout' do
    let!(:dept) { create :department }
    let(:person) { create :person }
    let(:flash_messages) { 'flash-messages' }
    let(:searchbox) { 'search-box' }

    before do
      omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
    end

    scenario 'display flash messages above search box for home page' do
      visit person_path(person)
      click_link 'Delete this profile'
      expect(current_path).to eql '/'
      expect(flash_messages).to appear_before searchbox
      expect(searchbox).not_to appear_before flash_messages
    end

    scenario 'display flash messages below search box' do
      visit group_path(dept)
      click_link 'Add new sub-team'
      fill_in 'Team name', with: 'Digital'
      click_button 'Save'
      expect(searchbox).not_to appear_before flash_messages
      expect(flash_messages).to appear_before searchbox
    end
  end
end
