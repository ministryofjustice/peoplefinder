require 'rails_helper'
require_relative './token_user_email_shared'

RSpec.shared_context "with token_auth feature disabled" do
  extend FeatureFlagSpecHelper
  disable_feature :token_auth
end

describe 'Token Authentication' do
  include ActiveJobHelper
  include PermittedDomainHelper

  let(:login_page) { Pages::Login.new }
  let(:edit_profile_page) { Pages::EditProfile.new }

  before do
    create(:group)
    ActionMailer::Base.deliveries = []
  end

  it 'trying to log in with a valid email address' do
    visit '/'
    fill_in 'token_user_email', with: 'valid.email@digital.justice.gov.uk'
    expect(TokenMailer).to receive(:new_token_email).at_least(:once).times.and_call_original
    click_button 'Request link'
    expect(page).to have_text('When it arrives, click on the link (which is active for 1 day)')
  end

  it 'trying to log in with an invalid email address' do
    visit '/'
    fill_in 'token_user_email', with: 'Bob'
    click_button 'Request link'
    expect(page).to have_text('Email address is not formatted correctly')
  end

  describe 'trying to log in more than 8 times per hour' do
    before do
      allow_any_instance_of(Token).to receive(:tokens_in_the_last_hour).and_return 8
    end

    it 'is not permitted' do
      visit '/'
      fill_in 'token_user_email', with: 'valid.email@digital.justice.gov.uk '
      click_button 'Request link'
      expect(page).to have_text('Email address has reached the limit of 8 tokens requested within an hour')
    end
  end

  it 'trying to log in with a non white-listed email address domain' do
    visit '/'
    fill_in 'token_user_email', with: 'bob@abscond.com'
    click_button 'Request link'
    expect(page).to have_text('Email address can’t be used to access People Finder')
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

  it 'following valid link from email and seeing my profile' do
    token = create(:token)
    visit token_path(token)
    expect(edit_profile_page).to be_displayed
    expect(page).to have_text('Signed in as')
  end

  it "logging in with a fake token" do
    visit token_path(id: "gobbledygoock")

    expect(page).to_not have_text('Signed in as')
    expect(page).to_not have_text('Start building your profile now')

    expect(page).to have_text("The authentication token has expired.")
  end

  it "logging in with a token that's more than 24 hours old" do
    token = create(:token, created_at: 25.hours.ago)
    visit token_path(token)

    expect(page).to_not have_text('Signed in as')
    expect(page).to_not have_text('Start building your profile now')

    expect(page).to have_text("The authentication token has expired.")
  end

  context "when logging in with a valid token" do
    let(:ff31) { 'Mozilla/5.0 (Windows NT 5.2; rv:31.0) Gecko/20100101 Firefox/31.0' }
    let(:ie6) { 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; SV1; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022)' }
    let(:token) { create(:token) }

    # This example formerly used JS driver, removed because we need to use webkit
    # in order to set the header on the driver
    # https://github.com/thoughtbot/capybara-webkit#non-standard-driver-methods
    context "when on an unsupported browser" do
      before do
        page.driver.header "User-Agent", ie6
        visit token_path(token)
      end

      it "displays unsupported browser warning page" do
        expect(page).to have_current_path(unsupported_browser_token_path(token))
        expect(page).to have_text 'You are nearly there...'
        expect(page).to have_text 'Internet Explorer 6.0'
        expect(page).to have_text token_path(token)
      end
    end

    # This example formerly used JS driver, removed because we need to use webkit
    # in order to set the header on the driver
    # https://github.com/thoughtbot/capybara-webkit#non-standard-driver-methods
    context "when on supported browser" do
      before do
        page.driver.header "User-Agent", ff31
        visit token_path(token)
      end

      it "does not redirect to unsupported browser warning page" do
        expect(edit_profile_page).to be_displayed
      end
    end
  end

  it "requesting more than 8 tokens per hour isn't permitted" do
    1.upto(9) do |count|
      visit '/'
      fill_in 'token_user_email', with: ' tony.stark@digital.justice.gov.uk '
      click_button 'Request link'
      if count < 9
        expect(page).to have_text('We’re just emailing you a link to access People Finder')
        expect(page).to_not have_text('reached the limit')
      else
        expect(page).not_to have_text('We’re just emailing you a link to access People Finder')
        expect(page).to have_text('Email address has reached the limit of 8 tokens requested within an hour')
      end
    end
  end

  it 'logging in and displaying a link to my profile' do
    person = create(:person, given_name: 'Bob', surname: 'Smith', email: 'test.user@digital.justice.gov.uk')
    token = Token.for_person(person)
    visit token_path(token)
    expect(page).to have_text('Signed in as Bob Smith')
    expect(page).to have_link('Bob Smith', href: person_path(person))
  end

  it 'logging out' do
    token_log_in_as('james.darling@digital.justice.gov.uk')
    expect(page).to have_text('James Darling')
    click_link 'Sign out'
    expect(page).not_to have_text('james.darling@digital.justice.gov.uk')
    expect(login_page).to be_displayed
  end

  it 'being inconsistent about capitalisation' do
    create(:person,
           given_name: 'Example',
           surname: 'User',
           email: 'example.user@digital.justice.gov.uk'
          )
    token_log_in_as('Example.USER@digital.justice.gov.uk')
    expect(page).to have_text('Signed in as Example User')
  end

  context 'when token_auth feature disabled' do
    include_context "with token_auth feature disabled"
    let(:token) { create(:token) }

    it 'following a valid link from an email redirects to login' do
      visit token_path(token)

      expect(page).to have_current_path(new_sessions_path, ignore_query: true)
      expect(page).to have_text('login link is invalid')
      expect(login_page).to be_displayed
    end

    it 'login page does not have token auth login option' do
      visit new_sessions_path
      expect(page).not_to have_css('form.new_token')
    end

    it 'attempting to create an authentication token redirects to login' do
      visit token_path(token)

      expect(page).to have_current_path(new_sessions_path, ignore_query: true)
      expect(page).to have_text('login link is invalid')
      expect(login_page).to be_displayed
    end
  end
end
