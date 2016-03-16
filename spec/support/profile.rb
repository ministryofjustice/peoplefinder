module SpecSupport
  module Profile
    def person_attributes
      {
        given_name: 'Marco',
        surname: 'Polo',
        email: 'marco.polo@digital.justice.gov.uk',
        primary_phone_number: '+44-208-123-4567',
        secondary_phone_number: '07777777777',
        location_in_building: '10.999',
        building: '102 Petty France',
        city: 'London',
        description: 'Lorem ipsum dolor sit amet...',
        current_project: 'Donec tincidunt luctus ullamcorper.'
      }
    end

    def complete_profile!(person)
      profile_photo = create(:profile_photo)
      person.update_attributes(
        person_attributes.
          except(:email).
          merge(profile_photo_id: profile_photo.id)
      )
      person.groups << create(:group)
    end

    def fill_in_complete_profile_details
      fill_in 'First name', with: person_attributes[:given_name]
      fill_in 'Surname', with: person_attributes[:surname]
      select_in_team_select 'Digital'
      fill_in 'Main email', with: person_attributes[:email]
      fill_in 'Main phone number', with: person_attributes[:primary_phone_number]
      fill_in 'Alternative phone number', with: person_attributes[:secondary_phone_number]
      fill_in 'Location in building', with: person_attributes[:location_in_building]
      fill_in 'Building', with: person_attributes[:building]
      fill_in 'City', with: person_attributes[:city]
      fill_in 'Extra information', with: person_attributes[:description]
      fill_in 'Current project(s)', with: person_attributes[:current_project]
      uncheck('Monday')
      uncheck('Friday')
    end

    def check_creation_of_profile_details
      name = "#{person_attributes[:given_name]} #{person_attributes[:surname]}"

      expect(page).to have_title("#{name} - #{app_title}")
      within('h1') { expect(page).to have_text(name) }
      expect(page).to have_text(person_attributes[:email])
      expect(page).to have_text(person_attributes[:primary_phone_number])
      expect(page).to have_text(person_attributes[:secondary_phone_number])
      expect(page).to have_text(person_attributes[:location_in_building])
      expect(page).to have_text(person_attributes[:building])
      expect(page).to have_text(person_attributes[:city])
      expect(page).to have_text(person_attributes[:description])
      expect(page).to have_text(person_attributes[:current_project])

      within('ul.working_days') do
        expect(page).to_not have_selector("li.active[alt='Monday']")
        expect(page).to have_selector("li.active[alt='Tuesday']")
        expect(page).to have_selector("li.active[alt='Wednesday']")
        expect(page).to have_selector("li.active[alt='Thursday']")
        expect(page).to_not have_selector("li.active[alt='Friday']")
        expect(page).to_not have_selector("li.active[alt='Saturday']")
        expect(page).to_not have_selector("li.active[alt='Sunday']")
      end
    end
  end
end
