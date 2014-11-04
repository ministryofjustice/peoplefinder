require 'rails_helper'

feature 'Person browsing' do
  before do
    omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario 'Using breadcrumbs on a profile page' do
    group_a = create_group_hierarchy('Ministry of Justice', 'Apple', 'Biwa')
    group_b = create_group_hierarchy('Ministry of Justice', 'Cherry', 'Durian')
    person = create(:person)
    create(:membership, person: person, group: group_a)
    create(:membership, person: person, group: group_b)

    visit group_path(group_b)
    click_link person.name

    expect(page).to have_selector('dd.breadcrumbs ol li a', text: 'Biwa')
    expect(page).to have_selector('dd.breadcrumbs ol li a', text: 'Durian')
  end

  describe 'Days worked' do
    let(:weekday_person) { create(:person, works_monday: true, works_friday: true) }
    let(:weekend_person) { create(:person, works_saturday: true, works_sunday: true) }

    scenario 'A person who only works weekdays should not see Saturday & Sunday listed' do
      visit person_path(weekday_person)
      expect(page).to have_xpath("//li[@alt='Monday']")
      expect(page).to have_xpath("//li[@alt='Friday']")

      expect(page).to_not have_xpath("//li[@alt='Sunday']")
      expect(page).to_not have_xpath("//li[@alt='Saturday']")
    end

    scenario 'A person who works one or more days on a weekend should have their days listed' do
      visit person_path(weekend_person)

      expect(page).to have_xpath("//li[@alt='Sunday']")
      expect(page).to have_xpath("//li[@alt='Saturday']")
    end

  end

  def create_group_hierarchy(*names)
    group = nil
    names.each do |name|
      group = Peoplefinder::Group.find_by_name(name) || create(:group, parent: group, name: name)
    end
    group
  end
end
