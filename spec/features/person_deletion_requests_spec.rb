require 'rails_helper'

feature 'Sending deletion requests' do
  include ActiveJobHelper
  include PermittedDomainHelper

  let(:requester) { create(:person, email: 'test.user@digital.justice.gov.uk') }
  let(:person) { create(:person, email: 'gone.user@digital.justice.gov.uk') }

  before do
    omni_auth_log_in_as(requester.email)
  end

  scenario 'Requesting a person to be deleted' do
    visit person_path(person)

    click_on "Has #{person.given_name} left the department?"
    fill_in 'note', with: 'They left the department in 2001.'

    expect do
      click_button 'Request deletion'
    end.to change { ActionMailer::Base.deliveries.count }.by(1)

    expect(page).to have_content("We'll review this profile")

    last_email = ActionMailer::Base.deliveries.last

    expect(last_email.reply_to).to include(requester.email)
    expect(last_email.to).to include(Rails.configuration.support_email)

    expect(last_email.body).to have_text(requester.name)
    expect(last_email.body).to have_text(requester.email)

    expect(last_email.body).to have_text(person.name)
    expect(last_email.body).to have_text(person_url(person))
  end
end
