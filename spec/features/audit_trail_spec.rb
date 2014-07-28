require 'rails_helper'

feature "Audit trail" do
  before do
    log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario 'Auditing an edit of a person' do
    with_versioning do
      person = create(:person, surname: 'original surname')
      visit edit_person_path(person)
      fill_in 'Surname', with: 'something else'
      click_button 'Update person'

      visit '/audit_trail'
      expect(page).to have_text('Person Edited')
      expect(page).to have_text('Surname changed from original surname to something else')
    end
  end

  scenario 'Auditing the creation of a person' do
    with_versioning do
      visit new_person_path
      fill_in 'Given name', with: 'Jon'
      fill_in 'Surname', with: 'Smith'
      click_button 'Create person'

      visit '/audit_trail'
      expect(page).to have_text('New Person')
      expect(page).to have_text('Given name set to: Jon')
      expect(page).to have_text('Surname set to: Smith')
    end
  end

  scenario 'Auditing the deletion of a person' do
    with_versioning do
      person = create(:person, surname: 'Dan', given_name: 'Greg')
      visit edit_person_path(person)
      click_link("Delete this profile")

      visit '/audit_trail'
      expect(page).to have_text('Deleted Person')
    end
  end

  scenario 'Auditing an edit of a group' do
    with_versioning do
      group = create(:group, name: 'original name')
      visit edit_group_path(group)
      fill_in 'Name', with: 'something else'
      click_button 'Update group'

      visit '/audit_trail'
      expect(page).to have_text('Group Edited')
      expect(page).to have_text('Name changed from original name to something else')
    end
  end

  scenario 'Auditing the creation of a group' do
    with_versioning do
      visit new_group_path
      fill_in 'Name', with: 'Jon'
      click_button 'Create group'

      visit '/audit_trail'
      expect(page).to have_text('New Group')
      expect(page).to have_text('Name set to: Jon')
    end
  end

  scenario 'Auditing the deletion of a group' do
    with_versioning do
      group = create(:group, name: 'original name')
      visit edit_group_path(group)
      click_link("Delete this record")

      visit '/audit_trail'
      expect(page).to have_text('Deleted Group')
    end
  end

  scenario 'Auditing the editing of a photo'

  scenario 'Auditing the creation of a membership'
  scenario 'Auditing the deletion of a membership'
  scenario 'Auditing the editing of a membership?'
end


