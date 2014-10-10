require 'rails_helper'

feature 'Audit trail' do
  before do
    omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario 'Auditing an edit of a person' do
    with_versioning do
      person = create(:person, surname: 'original surname')
      visit edit_person_path(person)
      fill_in 'Surname', with: 'something else'
      click_button 'Update'

      visit '/audit_trail'
      expect(page).to have_text('Peoplefinder::Person Edited')
      expect(page).to have_text('Surname changed from original surname to something else')

      click_button 'undo'

      person.reload
      expect(person.surname).to eq('original surname')
    end
  end

  scenario 'Auditing the creation of a person' do
    with_versioning do
      visit new_person_path
      fill_in 'First name', with: 'Jon'
      fill_in 'Surname', with: 'Smith'
      click_button 'Create'

      visit '/audit_trail'

      expect(page).to have_text('New Peoplefinder::Person')
      expect(page).to have_text('Given name set to: Jon')
      expect(page).to have_text('Surname set to: Smith')

      expect {
        click_button 'undo'
      }.to change(Peoplefinder::Person, :count).by(-1)
    end
  end

  scenario 'Auditing the deletion of a person' do
    with_versioning do
      person = create(:person, surname: 'Dan', given_name: 'Greg')
      visit edit_person_path(person)
      click_link('Delete this profile')

      visit '/audit_trail'
      expect(page).to have_text('Deleted Peoplefinder::Person')
      expect(page).to have_text('Name: Greg Dan')

      expect {
        click_button 'undo'
      }.to change(Peoplefinder::Person, :count).by(1)
    end
  end

  scenario 'Auditing an edit of a group' do
    with_versioning do
      group = create(:group, name: 'original name')
      visit edit_group_path(group)
      fill_in 'Team name', with: 'something else'
      click_button 'Update'

      visit '/audit_trail'
      expect(page).to have_text('Peoplefinder::Group Edited')
      expect(page).to have_text('Name changed from original name to something else')
    end
  end

  scenario 'Auditing the creation of a group' do
    with_versioning do
      visit new_group_path
      fill_in 'Team name', with: 'Jon'
      fill_in 'Team email address', with: 'something@example.com'
      click_button 'Create'

      visit '/audit_trail'
      expect(page).to have_text('New Peoplefinder::Group')
      expect(page).to have_text('Name set to: Jon')
    end
  end

  scenario 'Auditing the deletion of a group' do
    with_versioning do
      group = create(:group, name: 'original name')
      visit edit_group_path(group)
      click_link('Delete this team')

      visit '/audit_trail'
      expect(page).to have_text('Deleted Peoplefinder::Group')
      expect(page).to have_text('Name: original name')
    end
  end

  scenario 'Auditing the editing of a photo' do
    with_versioning do
      person = create(:person)
      visit edit_person_path(person)
      attach_file('person[image]', sample_image)
      click_button 'Update'

      visit '/audit_trail'
      expect(page).to have_text('Peoplefinder::Person Edited')
      expect(page).to have_text(/Image set to.*placeholder/)
    end
  end

  scenario 'Auditing the creation of a membership', js: true do
    with_versioning do
      create(:group, name: 'Digital Justice')
      person = create(:person, surname: 'Bob')
      javascript_log_in

      visit edit_person_path(person)
      click_in_org_browser 'Digital Justice'
      fill_in('Job title', with: 'Jefe')
      click_button 'Update'

      visit '/audit_trail'

      within('tbody tr:first-child') do
        expect(page).to have_text('New Peoplefinder::Membership')
        expect(page).to have_text('Person set to: Bob')
        expect(page).to have_text('Team set to: Digital Justice')
        expect(page).to have_text('Job title set to: Jefe')
        expect(page).to have_text('Leader set to: No')

        expect(page).not_to have_button 'undo'
      end
    end
  end

  scenario 'Auditing the deletion of a membership' do
    with_versioning do
      group = create(:group, name: 'Digital Justice')
      person = create(:person, surname: 'Bob')
      person.memberships.create(group: group, role: 'Jefe', leader: true)

      visit edit_person_path(person)
      within('.membership') do
        click_link('Delete')
      end

      visit '/audit_trail'

      within('tbody tr:first-child') do
        expect(page).to have_text('Deleted Peoplefinder::Membership')
        expect(page).to have_text('Person was: Bob')
        expect(page).to have_text('Team was: Digital Justice')
        expect(page).to have_text('Job title was: Jefe')
        expect(page).to have_text('Leader was: Yes')

        expect(page).not_to have_button 'undo'
      end
    end
  end
end
