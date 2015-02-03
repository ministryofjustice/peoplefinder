require 'rails_helper'

feature 'View person audit' do
  let(:email) { 'test.user@digital.justice.gov.uk' }
  let!(:person) { create(:person) }

  before do
    person.update_attributes description: 'The best person'
    person.update_attributes primary_phone_number: '55555555555'

    # login as a super admin
    create(:super_admin, email: email)
    omni_auth_log_in_as(email)
  end

  scenario 'View a profile as an admin user' do
    visit person_path(person)
    expect(page).to have_selector 'table.audit tbody tr', count: 3
  end
end
