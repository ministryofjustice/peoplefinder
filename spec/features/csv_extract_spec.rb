require 'rails_helper'

feature 'Super admin views CSV extracts' do
  include PermittedDomainHelper
  let(:email) { 'test.user@digital.justice.gov.uk' }

  before do
    create(:super_admin, email: email)
    omni_auth_log_in_as(email)
    click_link 'Manage'
  end

  scenario 'in general' do
    within('#csv-extract') { click_link 'download' }

    header = page.response_headers['Content-Disposition']
    expect(header).to match(/^attachment/)
    expect(header).to match(/filename="profiles-.*.csv"$/)

    expect(page).to have_text('Firstname,Surname,Email')

    person = Person.last
    person_fields = "#{person.given_name},#{person.surname},#{person.email}"
    expect(page).to have_text(person_fields)
  end
end
