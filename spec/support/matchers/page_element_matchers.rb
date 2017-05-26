RSpec::Matchers.define :have_profile_link do |expected|
  match do |actual|
    begin
      within '.profile-link' do
        actual.find_link(expected.name, href: person_path(expected)).present?
      end
    rescue
      false
    end
  end
  failure_message do |actual|
    "expected that #{actual} would have profile link for #{person_path(expected)}."
  end
end
