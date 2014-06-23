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
    within('h2.group-leader') do
      expect(page).to have_content('Doe')
    end
  end

  scenario 'Showing groups and roles on profile page' do
    membership = person.memberships.create!(group: group, role: 'Worker Bee')
    visit person_path(person)
    within('dl.person') do
      expect(page).to have_content('Digital Services')
      expect(page).to have_content('Worker Bee')
    end
  end
end
