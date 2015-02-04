require 'rails_helper'

feature 'View person audit' do
  let(:super_admin_email)  { 'test.user@digital.justice.gov.uk' }
  let!(:super_admin)  { create(:super_admin, email: super_admin_email) }

  let(:description)  { 'The best person' }
  let(:phone_number) { '55555555555' }
  let!(:person)      { with_versioning { create(:person) } }

  before do
    with_versioning do
      person.update description: description
      person.update primary_phone_number: phone_number
    end
  end

  scenario 'View audit as an admin user' do
    omni_auth_log_in_as(super_admin.email)
    visit person_path(person)

    expect(page).to have_selector 'table.audit tbody tr', count: 3
    within 'table.audit tbody' do
      expect(find('tr:nth-child(1)')).to have_text "primary_phone_number => #{phone_number}"
      expect(find('tr:nth-child(2)')).to have_text "description => #{description}"
      expect(find('tr:nth-child(3)')).to have_text "email => #{person.email}"
    end
  end

  scenario 'Hide audit as regular user' do
    omni_auth_log_in_as(person.email)
    visit person_path(person)
    expect(page).to_not have_selector 'table.audit'
  end
end
