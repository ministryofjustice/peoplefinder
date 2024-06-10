require "rails_helper"

describe "Login flow" do
  include PermittedDomainHelper

  let(:email) { "test.user@digital.justice.gov.uk" }
  let(:external_user) { create :external_user }
  let(:current_time) { Time.zone.now }

  let(:new_profile_page) { Pages::NewProfile.new }
  let(:edit_profile_page) { Pages::EditProfile.new }
  let(:new_group_page) { Pages::NewGroup.new }
  let(:edit_group_page) { Pages::EditGroup.new }
  let(:profile_page) { Pages::Profile.new }
  let(:login_page) { Pages::Login.new }
  let(:confirm_page) { Pages::PersonConfirm.new }
  let(:email_confirm_page) { Pages::PersonEmailConfirm.new }
  let(:base_page) { Pages::Base.new }
  let(:home_page) { Pages::Home.new }

  let(:profile_created_from_login_html) { "Your profile did not exist so we created it for you." }

  def token_login_step_with_expectation
    expect(login_page).to be_displayed
    token_log_in_as(email)
  end

  describe "Logging in as an external user" do
    it "When an external user logs in, they are directed to the homepage" do
      token_log_in_as(external_user.email)
      expect(home_page).to be_displayed
    end
  end

  describe "Choosing to login" do
    it "When a user logs in for the first time, they are directed to edit their profile" do
      token_log_in_as(email)
      expect(edit_profile_page).to be_displayed
    end

    it "When and existing user logs in, their profile page is displayed" do
      login_count = 5
      create(:person_with_multiple_logins, email:, login_count:)
      token_log_in_as(email)
      expect(profile_page).to be_displayed
    end

    it "Login counter is updated every time user logs in" do
      login_count = 3
      person = create(:person_with_multiple_logins, email:, login_count:)
      token_log_in_as(email)
      person.reload
      expect(person.login_count).to be(4)
    end

    it "When super user logs in they see the manage link in the banner" do
      create(:super_admin, email:)
      token_log_in_as(email)
      expect(base_page).to have_manage_link
    end

    it "When a normal user logs in they do not see the manage link in the banner" do
      create(:person, email:)
      token_log_in_as(email)
      expect(base_page).to have_no_manage_link
    end
  end

  describe "Prompted to login" do
    let(:group) { create :group }
    let(:other_person) { create :person }
    let(:create_profile_warning) { "You need to create or update a People Finder account to finish signing in" }

    context "when I have a profile" do
      it "attempting a new|edit action redirects via login back to that action's template page with NO flash notice" do
        create(:person, email:)
        visit new_group_path
        token_login_step_with_expectation
        expect(new_group_page).to be_displayed
        expect(new_group_page).not_to have_flash_message
      end
    end

    context "when I do not have a profile" do
      it "attempting a new|edit action redirects via login back to their own edit profile page and flashes a notice that their own profile was just created" do
        visit new_group_path
        token_login_step_with_expectation
        expect(edit_profile_page).to be_displayed
        expect(edit_profile_page).to have_flash_message
        expect(edit_profile_page.flash_message).to have_selector(".warning", text: create_profile_warning)
      end

      context "when I have namesakes" do
        let(:email) { "john.doe3@digital.justice.gov.uk" }

        before do
          create(:person, given_name: "John", surname: "Doe", email: "john.doe@digital.justice.gov.uk")
          create(:person, given_name: "Johnny", surname: "Doe-Smyth", email: "john.doe2@digital.justice.gov.uk")
        end

        it "I am redirected to person confirmation page" do
          visit new_group_path
          token_login_step_with_expectation
          expect(confirm_page).to be_displayed
          expect(confirm_page).to be_all_there
          expect(confirm_page.form).to be_visible
          expect(confirm_page).to have_content "Create profile"
          expect(confirm_page.person_confirm_results).to have_confirmation_results count: 2
          expect(confirm_page.person_confirm_results.name_links).to include "/people/john-doe"
        end

        it "confirming I need a new profile signs me in and redirects to edit my profile" do
          visit new_group_path
          token_login_step_with_expectation
          expect(confirm_page).to be_displayed
          expect(confirm_page.form).to have_continue_button
          confirm_page.form.continue_button.click
          person = Person.find_by(email:)
          expect(person).not_to be_nil
          expect(edit_profile_page).to be_displayed
          expect(edit_profile_page).to have_flash_message
          expect(edit_profile_page.flash_message).to have_selector(".warning", text: create_profile_warning)
          expect(edit_profile_page).to have_profile_link person
        end

        def when_i_am_prompted_to_login
          visit new_group_path
        end

        def and_i_login_using_token
          token_login_step_with_expectation
        end

        def then_the_confirmation_list_is_displayed_with(count: 2)
          expect(confirm_page).to be_displayed
          expect(confirm_page.person_confirm_results).to have_confirmation_results count:
        end

        def and_i_select_first_namesake
          confirm_page.person_confirm_results.select_buttons.first.click
        end

        def then_the_email_confirmation_page_is_displayed
          expect(email_confirm_page).to be_displayed
          expect(email_confirm_page).to have_form
          expect(email_confirm_page.form).to have_email_field
          expect(email_confirm_page.form).to have_secondary_email_field
          expect(email_confirm_page.form).to have_continue_button
        end

        def and_the_email_is_prefilled_with(email)
          expect(email_confirm_page.form.email_field.value).to eql email
        end

        def and_the_alternative_email_is_prefilled_with(email)
          expect(email_confirm_page.form.secondary_email_field.value).to eql email
        end

        def and_info_is_displayed(message_includes:)
          if message_includes.is_a?(Regexp)
            expect(email_confirm_page.info.text).to match(message_includes)
          else
            expect(email_confirm_page.info.text).to include message_includes
          end
        end

        def when_i_continue
          click_button "Continue"
        end

        def then_persons_email_is_updated(person:, new_email:)
          person.reload
          expect(person.email).to eql new_email
        end

        def then_profile_page_is_displayed_with_message_for(person:, message:)
          expect(profile_page).to be_displayed
          expect(profile_page).to have_profile_link person
          expect(profile_page).to have_flash_message
          expect(profile_page.flash_message).to have_selector(".notice", text: message)
        end

        def without_alternative_email_scenario
          person = Person.find_by(email: "john.doe@digital.justice.gov.uk")
          then_the_confirmation_list_is_displayed_with count: 2
          and_i_select_first_namesake
          then_the_email_confirmation_page_is_displayed
          and_the_email_is_prefilled_with email
          and_the_alternative_email_is_prefilled_with person.email
          and_info_is_displayed message_includes: /new email .* old email/i
          when_i_continue
          then_persons_email_is_updated person:, new_email: email
          then_profile_page_is_displayed_with_message_for person:, message: "Your main email has been updated to #{person.email}"
          expect(person.email).to eql email
        end

        def with_alternative_email_scenario
          person = Person.find_by(email: "john.doe@digital.justice.gov.uk")
          person.update(secondary_email: "john.doe+1@digital.justice.gov.uk") # rubocop:disable Rails/SaveBang

          then_the_confirmation_list_is_displayed_with count: 2
          and_i_select_first_namesake
          then_the_email_confirmation_page_is_displayed
          and_the_email_is_prefilled_with email
          and_the_alternative_email_is_prefilled_with person.secondary_email
          and_info_is_displayed message_includes: person.email
          when_i_continue
          then_persons_email_is_updated person:, new_email: email
          then_profile_page_is_displayed_with_message_for person:, message: "Your main email has been updated to #{person.email}"
          expect(person.email).to eql email
        end

        context "when selecting an existing namesake" do
          context "when using token login" do
            before do
              when_i_am_prompted_to_login
              and_i_login_using_token
            end

            it "with an alternative email" do
              with_alternative_email_scenario
            end

            it "without an alternative email" do
              without_alternative_email_scenario
            end
          end
        end
      end
    end
  end
end
