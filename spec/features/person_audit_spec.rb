require 'rails_helper'

feature 'View person audit' do
  let(:super_admin_email)  { 'test.user@digital.justice.gov.uk' }
  let!(:super_admin)  { create(:super_admin, email: super_admin_email) }

  let(:description)  { 'The best person' }
  let(:phone_number) { '55555555555' }
  let!(:person)      { with_versioning { create(:person) } }
  let(:profile_page) { Pages::Profile.new }

  before do
    with_versioning do
      person.update description: description
      person.update primary_phone_number: phone_number
    end
  end

  scenario 'View audit as an admin user' do
    omni_auth_log_in_as(super_admin.email)
    profile_page.load(slug: person.slug)

    expect(profile_page).to have_audit
    profile_page.audit.versions.tap do |v|
      expect(v[0]).to have_text "primary_phone_number => #{phone_number}"
      expect(v[1]).to have_text "description => #{description}"
      expect(v[2]).to have_text "email => #{person.email}"
    end
  end

  scenario 'Hide audit as regular user' do
    omni_auth_log_in_as(person.email)
    profile_page.load(slug: person.slug)
    expect(profile_page).to_not have_audit
  end
end
