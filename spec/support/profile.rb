module SpecSupport
  module Profile # rubocop:disable Metrics/ModuleLength
    def person_attributes
      {
        given_name: 'Marco',
        surname: 'Polo',
        email: 'marco.polo@digital.justice.gov.uk',
        primary_phone_number: '0208-123-4567',
        primary_phone_country_code: 'GB',
        secondary_phone_number: '718-555-1212',
        secondary_phone_country_code: 'US',
        pager_number: '07666666666',
        location_in_building: '10.999',
        city: 'London',
        country: 'United Kingdom'
      }
    end

    def membership_attributes
      {
        role: 'The boss',
        group_id: Group.first.id || create(:group).id,
        leader: true,
        subscribed: false
      }
    end

    def complete_profile!(person)
      profile_photo = create(:profile_photo)
      person.update_attributes(
        person_attributes.
          except(:email).
          merge(profile_photo_id: profile_photo.id, country: 'GB')
      )
      person.groups << create(:group)
    end

    def govuk_label_click locator
      el = page.find("label[for='#{locator}']")
    rescue
      nil
    ensure
      el ||= page.find('label', text: locator)
      el.click
    end

    def fill_in_complete_profile_details
      fill_in 'First name', with: person_attributes[:given_name]
      fill_in 'Last name', with: person_attributes[:surname]
      select_in_team_select 'Digital'
      fill_in 'Primary work email', with: person_attributes[:email]
      fill_in 'Mobile number', with: person_attributes[:primary_phone_number]
      fill_in 'Landline number', with: person_attributes[:secondary_phone_number]
      fill_in 'Location in building', with: person_attributes[:location_in_building]
      fill_in 'City', with: person_attributes[:city]
      select person_attributes[:country], from: 'Country (Market)', match: :first

      within_fieldset('working-days') do
        govuk_label_click 'Monday'
        govuk_label_click 'Friday'
      end

      within '#key_skills' do
        govuk_label_click 'Assurance'
      end
      fill_in 'Other key skills', with: 'Laughing'

      fill_in 'Fluent languages', with: 'English'
      fill_in 'Intermediate languages', with: 'Dutch'
      select 'Apprentice', from: 'Grade'
      fill_in 'Previous positions held', with: 'Task rabbit'

      within '#learning_and_development' do
        govuk_label_click 'Coding'
      end
      fill_in 'Other learning and development', with: 'Walking, Talking'

      within '#networks' do
        govuk_label_click 'Age network'
      end

      within '#professions' do
        govuk_label_click 'Government communication service'
      end

      within '#additional_responsibilities' do
        govuk_label_click 'First aider'
      end
      fill_in 'Other additional roles', with: 'lifeguard, beekeper'
    end

    def click_edit_profile(matcher = :first)
      click_link('Edit this profile', match: matcher)
    end

    def click_delete_profile(matcher = :first)
      click_link('Delete this profile', match: matcher)
    end

    def fill_in_membership_details(team_name)
      fill_in 'Job title', with: membership_attributes[:role]
      select_in_team_select(team_name)
      within '.team-leader' do
        govuk_label_click(membership_attributes[:leader] ? 'Yes' : 'No')
      end
      within '.team-subscribed' do
        govuk_label_click(membership_attributes[:subscribed] ? 'Yes' : 'No')
      end
    end

    def check_creation_of_profile_details
      name = "#{person_attributes[:given_name]} #{person_attributes[:surname]}"

      expect(page).to have_title("#{name} - #{app_title}")
      within('h1') { expect(page).to have_text(name) }
      expect(page).to have_text(person_attributes[:email])
      expect(page).to have_text(person_attributes[:primary_phone_number])
      expect(page).to have_text(person_attributes[:secondary_phone_number])
      expect(page).to have_text(person_attributes[:location_in_building])
      expect(page).to have_text(person_attributes[:city])
      expect(page).to have_text(person_attributes[:country])

      within('ul.working_days') do
        expect(page).to_not have_selector("li.active[alt='Monday']")
        expect(page).to have_selector("li.active[alt='Tuesday']")
        expect(page).to have_selector("li.active[alt='Wednesday']")
        expect(page).to have_selector("li.active[alt='Thursday']")
        expect(page).to_not have_selector("li.active[alt='Friday']")
        expect(page).to_not have_selector("li.active[alt='Saturday']")
        expect(page).to_not have_selector("li.active[alt='Sunday']")
      end

      within '#key_skills' do
        expect(page).to have_text('Assurance, Laughing')
      end

      within '#language_fluent' do
        expect(page).to have_text('English')
      end

      within '#language_intermediate' do
        expect(page).to have_text('Dutch')
      end

      within('#grade') do
        expect(page).to have_text('Apprentice')
      end

      within('#previous_positions') do
        expect(page).to have_text('Task rabbit')
      end

      within '#learning_and_development' do
        expect(page).to have_text('Coding, Walking, Talking')
      end

      within '#networks' do
        expect(page).to have_text('Age network')
      end

      within '#professions' do
        expect(page).to have_text('Government communication service')
      end

      within '#additional_responsibilities' do
        expect(page).to have_text('First aider, lifeguard, beekeper')
      end
    end
  end
end
