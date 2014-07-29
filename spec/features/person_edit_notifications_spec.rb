require 'rails_helper'

feature "Person edit notifications" do
  before do
    log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario "Creating a person with different email" do
    visit new_person_path

    fill_in 'Given name', with: "Bob"
    fill_in 'Surname', with: "Smith"
    fill_in 'Email', with: 'bob.smith@digital.justice.gov.uk'
    expect { click_button "Create person" }.to change { ActionMailer::Base.deliveries.count }.by(1)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.subject).to eq("A new profile on MOJ People Finder has been created for you")
    expect(mail.to).to eql(['bob.smith@digital.justice.gov.uk'])
    expect(mail.body.encoded).to match(person_url(Person.last))
    expect(mail.body.encoded).to match('test.user@digital.justice.gov.uk')
  end

  scenario "Creating a person with same email" do
    visit new_person_path

    fill_in 'Given name', with: "Bob"
    fill_in 'Surname', with: "Smith"
    fill_in 'Email', with: 'test.user@digital.justice.gov.uk'
    expect { click_button "Create person" }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario "Creating a person with invalid email" do
    visit new_person_path

    fill_in 'Given name', with: "Bob"
    fill_in 'Surname', with: "Smith"
    fill_in 'Email', with: 'test.user'
    expect { click_button "Create person" }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario "Creating a person with nil email" do
    visit new_person_path

    fill_in 'Given name', with: "Bob"
    fill_in 'Surname', with: "Smith"
    expect { click_button "Create person" }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario 'Deleting a person with different email' do
    person = create(:person, :email => 'bob.smith@digital.justice.gov.uk')
    visit edit_person_path(person)
    expect { click_link('Delete this profile') }.to change { ActionMailer::Base.deliveries.count }.by(1)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.subject).to eq("Your profile on MOJ People Finder has been deleted")
    expect(mail.to).to eql(['bob.smith@digital.justice.gov.uk'])
    expect(mail.body.encoded).to match('test.user@digital.justice.gov.uk')
  end

  scenario 'Deleting a person with same email' do
    person = create(:person, :email => 'test.user@digital.justice.gov.uk')
    visit edit_person_path(person)
    expect { click_link('Delete this profile') }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario 'Deleting a person with invalid email' do
    person = create(:person, :email => 'test.user')
    visit edit_person_path(person)
    expect { click_link('Delete this profile') }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario 'Deleting a person with nil email' do
    person = create(:person, :email => nil)
    visit edit_person_path(person)
    expect { click_link('Delete this profile') }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario 'Editing a person with different email' do
    person = create(:person, :given_name => 'Bob', :surname => 'Smith', :email => 'bob.smith@digital.justice.gov.uk')
    visit person_path(person)
    click_link 'Edit this page'
    fill_in 'Surname', with: 'Smelly Pants'
    expect { click_button 'Update person' }.to change { ActionMailer::Base.deliveries.count }.by(1)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.subject).to eq("Your profile on MOJ People Finder has been edited")
    expect(mail.to).to eql(['bob.smith@digital.justice.gov.uk'])
    expect(mail.body.encoded).to match(person_url(person))
    expect(mail.body.encoded).to match('test.user@digital.justice.gov.uk')
  end

  scenario 'Editing a person with same email' do
    person = create(:person, :given_name => 'Bob', :surname => 'Smith', :email => 'test.user@digital.justice.gov.uk')
    visit person_path(person)
    click_link 'Edit this page'
    fill_in 'Surname', with: 'Smelly Pants'
    expect { click_button 'Update person' }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario 'Editing a person with nil email' do
    person = create(:person, :given_name => 'Bob', :surname => 'Smith', :email => nil)
    visit person_path(person)
    click_link 'Edit this page'
    fill_in 'Surname', with: 'Smelly Pants'
    expect { click_button 'Update person' }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario 'Editing a person with invalid email' do
    person = create(:person, :given_name => 'Bob', :surname => 'Smith', :email => 'test.user')
    visit person_path(person)
    click_link 'Edit this page'
    fill_in 'Surname', with: 'Smelly Pants'
    expect { click_button 'Update person' }.not_to change { ActionMailer::Base.deliveries.count }
  end

  scenario 'Editing a person from same email to different email' do
    person = create(:person, :given_name => 'Bob', :surname => 'Smith', :email => 'test.user@digital.justice.gov.uk')
    visit person_path(person)
    click_link 'Edit this page'
    fill_in 'Email', with: 'bob.smith@digital.justice.gov.uk'
    expect { click_button 'Update person' }.to change { ActionMailer::Base.deliveries.count }.by(1)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.subject).to eq("This email address has been added to a profile on MOJ People Finder")
    expect(mail.to).to eql(['bob.smith@digital.justice.gov.uk'])
    expect(mail.body.encoded).to match(person_url(person))
    expect(mail.body.encoded).to match('test.user@digital.justice.gov.uk')
  end

  scenario 'Editing a person from different email to same email' do
    person = create(:person, :given_name => 'Bob', :surname => 'Smith', :email => 'bob.smith@digital.justice.gov.uk')
    visit person_path(person)
    click_link 'Edit this page'
    fill_in 'Email', with: 'test.user@digital.justice.gov.uk'
    expect { click_button 'Update person' }.to change { ActionMailer::Base.deliveries.count }.by(1)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.subject).to eq("This email address has been removed from a profile on MOJ People Finder")
    expect(mail.to).to eql(['bob.smith@digital.justice.gov.uk'])
    expect(mail.body.encoded).to match(person_url(person))
    expect(mail.body.encoded).to match('test.user@digital.justice.gov.uk')
  end

  scenario 'Editing a person from different email to different email' do
    person = create(:person, :given_name => 'Bob', :surname => 'Smith', :email => 'bob.smith@digital.justice.gov.uk')
    visit person_path(person)
    click_link 'Edit this page'
    fill_in 'Email', with: 'bob.smithe@digital.justice.gov.uk'
    expect { click_button 'Update person' }.to change { ActionMailer::Base.deliveries.count }.by(2)
  end

  scenario 'Editing a person from invalid email to invalid email' do
    person = create(:person, :given_name => 'Bob', :surname => 'Smith', :email => 'bob.smith')
    visit person_path(person)
    click_link 'Edit this page'
    fill_in 'Email', with: 'test.user'
    expect { click_button 'Update person' }.not_to change { ActionMailer::Base.deliveries.count }
  end
end
