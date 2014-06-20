require 'rails_helper'

feature "Membership maintenance" do
  let!(:person) { create(:person, surname: 'Doe') }
  let!(:group) { create(:group, name: 'Digital Services') }

  before do
    log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario 'Adding a person to a group' do
    visit edit_person_path(person)
    within('div.membership') { click_link('Add another') }
    fill_in 'Role', with: 'Designer'
    select 'Doe', from: 'Person'
    select 'Digital Services', from: 'Group'
    click_button 'Create Membership'

    expect(person.groups).to include(group)
    expect(person.memberships.first.role).to eql('Designer')
  end

  scenario 'Making someone the leader of a group' do
     membership = person.memberships.create!(group: group, role: 'Jefe')
     visit edit_membership_path(membership)
     check('Leader')
     click_button 'Update Membership'

     visit group_path(group)
     expect(page).to have_content('Leader: Doe')
     click_link('Doe')
   end
end
