require 'rails_helper'
require_relative './token_user_email_shared'

RSpec.shared_context "token_auth feature disabled" do
  extend FeatureFlagSpecHelper
  disable_feature :token_auth
end


feature 'Token Authentication' do
  include ActiveJobHelper
  include PermittedDomainHelper

  let(:login_page) { Pages::Login.new }

  before do
    create(:group)
    ActionMailer::Base.deliveries = []
  end

  scenario 'trying to log in with an invalid email address' do
    visit '/'
    fill_in 'token_user_email', with: 'Bob'
    expect { click_button 'Request link' }.not_to change { ActionMailer::Base.deliveries.count }
    expect(page).to have_text('Email address is not formatted correctly')
  end

  describe 'trying to log in with a non-whitelisted email address domain' do
    describe 'does not leak username information' do
      it_should_behave_like "it received a valid request from" do
        let(:email) { 'james@abscond.com' }
        let(:sent_to) { '' }
      end
    end
  end

  describe 'bad email from valid domain' do
    it_should_behave_like "it received a valid request from" do
      let(:email) { 'no.user.by.that.name@digital.justice.gov.uk' }
      let(:sent_to) { 'no.user.by.that.name@digital.justice.gov.uk' }
    end
  end

  describe 'accurate email' do
    it_should_behave_like "it received a valid request from" do
      let(:email) { 'james.darling@digital.justice.gov.uk' }
      let(:sent_to) { 'james.darling@digital.justice.gov.uk' }
    end
  end

  describe 'copy-pasting an email with extraneous spaces' do
    it_should_behave_like "it received a valid request from" do
      let(:email) { ' correct@digital.justice.gov.uk' }
      let(:sent_to) { 'correct@digital.justice.gov.uk' }
    end
  end

  scenario 'following valid link from email and getting prompted to complete my profile' do
    token = create(:token)
    visit token_path(token)

    expect(page).to have_text('Signed in as')
    expect(page).to have_text('Start building your profile now')
    within('h1') do
      expect(page).to have_text('Edit profile')
    end
  end

  scenario "logging in with a fake token" do
    visit token_path(id: "gobbledygoock")

    expect(page).to_not have_text('Signed in as')
    expect(page).to_not have_text('Start building your profile now')

    expect(page).to have_text("The authentication token doesn’t exist and so isn’t valid")
  end

  scenario "logging in with a token that's more than 3 hours old" do
    token = create(:token, created_at: 4.hours.ago)
    visit token_path(token)

    expect(page).to_not have_text('Signed in as')
    expect(page).to_not have_text('Start building your profile now')

    expect(page).to have_text("The authentication token has expired and is more than 3 hours old")
  end

  scenario "requesting more than 8 tokens per hour isn't permitted" do
    1.upto(9) do |count|
      visit '/'
      fill_in 'token_user_email', with: ' tony.stark@digital.justice.gov.uk '
      click_button 'Request link'
      if count < 9
        expect(page).to have_text('We’re just emailing you a link to access People Finder')
        expect(page).to_not have_text("You’ve reached the limit of 8 tokens requested within an hour")
      else
        expect(page).not_to have_text('We’re just emailing you a link to access People Finder')
        expect(page).to have_text("You’ve reached the limit of 8 tokens requested within an hour")
      end
    end
  end

  scenario 'logging in and displaying a link to my profile' do
    person = create(:person, given_name: 'Bob', surname: 'Smith', email: 'test.user@digital.justice.gov.uk')
    token = Token.for_person(person)
    visit token_path(token)
    expect(page).to have_text('Signed in as Bob Smith')
    expect(page).to have_link('Bob Smith', href: person_path(person))
  end

  scenario 'logging out' do
    token_log_in_as('james.darling@digital.justice.gov.uk')
    expect(page).to have_text('James Darling')
    click_link 'Sign out'
    expect(page).not_to have_text('james.darling@digital.justice.gov.uk')
    expect(login_page).to be_displayed
  end

  scenario 'being inconsistent about capitalisation' do
    create(:person,
      given_name: 'Example',
      surname: 'User',
      email: 'example.user@digital.justice.gov.uk'
    )
    token_log_in_as('Example.USER@digital.justice.gov.uk')
    expect(page).to have_text('Signed in as Example User')
  end

  context 'token_auth feature disabled' do
    include_context "token_auth feature disabled"
    let(:token) { create(:token) }

    scenario 'following a valid link from an email redirects to login' do
      visit token_path(token)

      expect(page.current_path).to eq(new_sessions_path)
      expect(page).to have_text('login link is invalid')
      expect(login_page).to be_displayed
    end

    scenario 'login page does not have token auth login option' do
      visit new_sessions_path
      expect(page).not_to have_css('form.new_token')
    end

    scenario 'attempting to create an authentication token redirects to login' do
      visit token_path(token)

      expect(page.current_path).to eq(new_sessions_path)
      expect(page).to have_text('login link is invalid')
      expect(login_page).to be_displayed
    end
  end
end
