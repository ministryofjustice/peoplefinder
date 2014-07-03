require 'rails_helper'

feature "Person browsing" do
  before do
    log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario "Using breadcrumbs on a profile page" do
    group_a = create_group_hierarchy("Ministry of Justice", "Apple", "Biwa")
    group_b = create_group_hierarchy("Ministry of Justice", "Cherry", "Durian")
    person = create(:person)
    create(:membership, person: person, group: group_a)
    create(:membership, person: person, group: group_b)

    visit group_path(group_b)
    click_link person.name

    within ".breadcrumbs" do
      expect(page).to have_selector("a", text: "Durian")
      expect(page).not_to have_selector("a", text: "Biwa")
    end
  end

  def create_group_hierarchy(*names)
    group = nil
    names.each do |name|
      group = Group.find_by_name(name) || create(:group, parent: group, name: name)
    end
    group
  end
end
