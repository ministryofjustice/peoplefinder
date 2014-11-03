module SpecSupport
  module Profile
    def person_attributes
      {
        given_name: 'Marco',
        surname: 'Polo',
        email: 'marco.polo@example.com',
        primary_phone_number: '+44-208-123-4567',
        secondary_phone_number: '07777777777',
        location: 'MOJ / Petty France / London',
        description: 'Lorem ipsum dolor sit amet...',
        image: Rack::Test::UploadedFile.new(sample_image)
      }
    end

    def complete_profile!(person)
      person.update_attributes(person_attributes.except(:email))
      person.groups << create(:group)
    end

    def fill_in_complete_profile_details
      fill_in 'First name', with: person_attributes[:given_name]
      fill_in 'Surname', with: person_attributes[:surname]
      click_in_org_browser 'Digital'
      fill_in 'Email', with: person_attributes[:email]
      fill_in 'Primary phone number', with: person_attributes[:primary_phone_number]
      fill_in 'Any other phone number', with: person_attributes[:secondary_phone_number]
      fill_in 'Location', with: person_attributes[:location]
      fill_in 'Notes', with: person_attributes[:description]
      uncheck('Monday')
      uncheck('Friday')
      attach_file 'person[image]', sample_image
    end

    def check_creation_of_profile_details
      click_button 'Update Image'
      person = Peoplefinder::Person.last

      expect(page).to have_title("#{ person } - #{ app_title }")
      within('h1') { expect(page).to have_text(person) }
      expect(page).to have_text(person_attributes[:email])
      expect(page).to have_text(person_attributes[:primary_phone_number])
      expect(page).to have_text(person_attributes[:secondary_phone_number])
      expect(page).to have_text(person_attributes[:location])
      expect(page).to have_text(person_attributes[:description])

      within('ul.working_days') do
        expect(page).to_not have_selector("li.active[alt='Monday']")
        expect(page).to have_selector("li.active[alt='Tuesday']")
        expect(page).to have_selector("li.active[alt='Wednesday']")
        expect(page).to have_selector("li.active[alt='Thursday']")
        expect(page).to_not have_selector("li.active[alt='Friday']")
        expect(page).to_not have_selector("li.active[alt='Saturday']")
        expect(page).to_not have_selector("li.active[alt='Sunday']")
      end

      expect(page).to have_css("img[src*='medium_placeholder.png']")
    end
  end
end
