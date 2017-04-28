require 'rails_helper'

feature 'Make a suggestion about a profile', js: true do
  include ActiveJobHelper
  include PermittedDomainHelper

  let(:me) { create(:person) }
  let(:leader) { create(:person) }
  let(:group) do
    create(:group).tap do |group|
      create(:membership, person: leader, group: group, leader: true)
    end
  end
  let(:subject) do
    create(:person).tap do |subject|
      create(:membership, person: subject, group: group)
    end
  end

  before(:each, user: :regular) do
    omni_auth_log_in_as(me.email)
    javascript_log_in
    visit person_path(subject)
    click_link 'Help improve this profile', match: :first
  end

  before(:each, user: :readonly) do
    mock_readonly_user
    visit person_path(subject)
  end

  scenario 'Readonly user tries to improve profile', js: false, user: :readonly do
    click_link 'Help improve this profile', match: :first
    expect(Pages::Login.new).to be_displayed
    expect(page).to have_text('Log in to edit People Finder')
  end

  scenario 'Ask a person to complete missing fields', user: :regular do
    govuk_label_click 'Fill missing fields'
    fill_in 'Missing fields', with: 'Write more stuff'
    click_button 'Submit'

    expect(page).to have_text('We’ve sent an email to the relevant person')

    expect(last_email.to).to eql([subject.email])
    expect(last_email.body.encoded).to have_text('Write more stuff')
  end

  scenario 'Ask a person to update incorrect fields', user: :regular do
    govuk_label_click 'Update incorrect fields'
    govuk_label_click 'Last name'
    click_button 'Submit'

    expect(page).to have_text('We’ve sent an email to the relevant person')

    expect(last_email.to).to eql([subject.email])
    expect(last_email.body.encoded).to have_text('* Last name')
  end

  scenario 'Ask an admin to remove duplicate profile', user: :regular do
    govuk_label_click 'Remove duplicate profile'
    click_button 'Submit'

    expect(page).to have_text('We’ve sent an email to the relevant person')

    expect(last_email.to).to eql([leader.email])
    expect(last_email.body.encoded).to have_text('duplicate profile')
  end

  scenario 'Ask an admin to remove inappropriate content', user: :regular do
    govuk_label_click 'Remove inappropriate content'
    fill_in 'Inappropriate content', with: 'Outrageous!'
    click_button 'Submit'

    expect(page).to have_text('We’ve sent an email to the relevant person')

    expect(last_email.to).to eql([leader.email])
    expect(last_email.body.encoded).to have_text('Outrageous!')
  end

  scenario 'Ask an admin to remove the profile', user: :regular do
    govuk_label_click 'Remove the profile as the person has left MOJ'
    fill_in 'Additional information', with: 'They have left to become a goatherd'
    click_button 'Submit'

    expect(page).to have_text('We’ve sent an email to the relevant person')

    expect(last_email.to).to eql([leader.email])
    expect(last_email.body.encoded).to have_text('They have left to become a goatherd')
  end

  scenario 'Send multiple emails', user: :regular do
    another_leader = create(:person)
    create(:membership, person: another_leader, group: group, leader: true)

    govuk_label_click 'Fill missing fields'
    fill_in 'Missing fields', with: 'Write more stuff'
    govuk_label_click 'Remove inappropriate content'
    fill_in 'Inappropriate content', with: 'Outrageous!'
    click_button 'Submit'

    expect(page).to have_text('We’ve sent emails to the relevant people')

    recipients = ActionMailer::Base.deliveries.flat_map(&:to).uniq

    [subject, leader, another_leader].each do |person|
      expect(recipients).to include(person.email)
    end
  end
end
