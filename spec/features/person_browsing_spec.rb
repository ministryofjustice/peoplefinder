require "rails_helper"

describe "Person browsing" do
  include PermittedDomainHelper

  let(:department) { create(:department) }

  before do
    department
    token_log_in_as "test.user@digital.justice.gov.uk"
  end

  it "Using breadcrumbs on a profile page", skip: "HELP REQUIRED" do
    group_a = create_group_hierarchy("Ministry of Justice", "Apple", "Biwa")
    group_b = create_group_hierarchy("Ministry of Justice", "Cherry", "Durian")
    person = create(:person)
    create(:membership, person:, group: group_a)
    create(:membership, person:, group: group_b)

    visit group_path(group_b)
    click_link person.name

    expect(page).to have_selector("dd.breadcrumbs ol li a", text: "Biwa")
    expect(page).to have_selector("dd.breadcrumbs ol li a", text: "Durian")
  end

  describe "Days worked" do
    let(:weekday_person) { create(:person, works_monday: true, works_friday: true) }
    let(:weekend_person) { create(:person, works_saturday: true, works_sunday: true) }

    it "A person who only works weekdays should not see Saturday & Sunday listed" do
      visit person_path(weekday_person)
      expect(page).to have_xpath("//li[@alt='Monday']")
      expect(page).to have_xpath("//li[@alt='Friday']")

      expect(page).not_to have_xpath("//li[@alt='Sunday']")
      expect(page).not_to have_xpath("//li[@alt='Saturday']")
    end

    it "A person who works one or more days on a weekend should have their days listed" do
      visit person_path(weekend_person)

      expect(page).to have_xpath("//li[@alt='Sunday']")
      expect(page).to have_xpath("//li[@alt='Saturday']")
    end
  end

  def create_group_hierarchy(*names)
    group = nil
    names.each do |name|
      group = Group.find_by_name(name) || create(:group, parent: group, name:)
    end
    group
  end
end
