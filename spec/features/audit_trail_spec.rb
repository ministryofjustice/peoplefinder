require 'rails_helper'

feature "Audit trail" do
  before do
    log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario 'Auditing a person model' do
    with_versioning do
      person = create(:person, surname: 'original surname')
      visit edit_person_path(person)
      fill_in 'Surname', with: 'something else'
      click_button 'Update Person'
      expect(person.versions.last.changeset['surname']).to eql(['original surname', 'something else'])

      visit '/audit_trail'
      expect(page).to have_text('Surname changed from: original surname to: something else')
    end
  end
end


