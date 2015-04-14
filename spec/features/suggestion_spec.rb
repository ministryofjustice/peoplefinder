require 'rails_helper'

feature 'Make a suggestion about a profile', js: true do
  include ActiveJobHelper
  include PermittedDomainHelper

  let(:me) { create(:person) }
  let(:leader) { create(:person) }
  let(:group) {
    create(:group).tap { |group|
      create(:membership, person: leader, group: group, leader: true)
    }
  }
  let(:subject) {
    create(:person).tap { |subject|
      create(:membership, person: subject, group: group)
    }
  }

  before do
    omni_auth_log_in_as(me.email)
    javascript_log_in
    visit person_path(subject)
    click_link 'Help improve this profile'
  end

  scenario 'Ask a person to complete missing fields' do
    check 'fill missing fields'
    fill_in 'Missing fields info', with: 'Write more stuff'
    click_button 'Submit'

    expect(page).to have_text('We’ve sent an email to the relevant person')

    expect(last_email.to).to eql([subject.email])
    expect(last_email.body.encoded).to have_text('Write more stuff')
  end

  scenario 'Ask a person to update incorrect fields' do
    check 'update incorrect fields'
    check 'Last name'
    click_button 'Submit'

    expect(page).to have_text('We’ve sent an email to the relevant person')

    expect(last_email.to).to eql([subject.email])
    expect(last_email.body.encoded).to have_text('* Last name')
  end

  scenario 'Ask an admin to remove duplicate profile' do
    check 'remove duplicate profile'
    click_button 'Submit'

    expect(page).to have_text('We’ve sent an email to the relevant person')

    expect(last_email.to).to eql([leader.email])
    expect(last_email.body.encoded).to have_text('duplicate profile')
  end

  scenario 'Ask an admin to remove inappropriate content' do
    check 'remove inappropriate content'
    fill_in 'Inappropriate content info', with: 'Outrageous!'
    click_button 'Submit'

    expect(page).to have_text('We’ve sent an email to the relevant person')

    expect(last_email.to).to eql([leader.email])
    expect(last_email.body.encoded).to have_text('Outrageous!')
  end

  scenario 'Ask an admin to remove the profile' do
    check 'remove the profile as the person has left MOJ'
    fill_in 'Person left info', with: 'They have left to become a goatherd'
    click_button 'Submit'

    expect(page).to have_text('We’ve sent an email to the relevant person')

    expect(last_email.to).to eql([leader.email])
    expect(last_email.body.encoded).to have_text('They have left to become a goatherd')
  end

  scenario 'Send multiple emails' do
    another_leader = create(:person)
    create(:membership, person: another_leader, group: group, leader: true)

    check 'fill missing fields'
    fill_in 'Missing fields info', with: 'Write more stuff'
    check 'remove inappropriate content'
    fill_in 'Inappropriate content info', with: 'Outrageous!'
    click_button 'Submit'

    expect(page).to have_text('We’ve sent emails to the relevant people')

    recipients = ActionMailer::Base.deliveries.flat_map(&:to).uniq

    [subject, leader, another_leader].each do |person|
      expect(recipients).to include(person.email)
    end
  end
end
