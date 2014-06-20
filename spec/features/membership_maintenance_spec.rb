require 'rails_helper'

feature "Membership maintenance" do
  before do
    log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario 'Adding a person to a group' do
    person = create(:person, surname: 'Doe')
    group = create(:group, name: 'Digital Services')

    visit edit_person_path(person)
    within('div.membership') { click_link('Add another') }
  end
end
