module SpecSupport
  module SharedSteps
    class StrictHash < SimpleDelegator
      def initialize(hash = {})
        super(hash)
      end

      def [](k)
        __getobj__.fetch(k)
      end
    end

    def state
      @shared_state ||= StrictHash.new
    end

    def given_i_have_an_account
      state[:password] = generate(:password)
      state[:me] = create(:user, password: state[:password])
    end

    def and_i_have_no_emails
      clear_emails
    end

    def and_i_have_an_agreement_as_a_staff_member
      state[:agreement] = create(:agreement, staff_member: state[:me])
    end

    def and_i_am_logged_in
      log_in_as state[:me].email, state[:password]
    end

    def when_i_visit_the_home_page
      visit '/'
    end

    def and_i_enter_my_email
      fill_in 'Email', with: state[:me].email
    end

    def and_i_enter_an_unregistered_email
      fill_in 'Email', with: generate(:email)
    end

    def and_i_enter_my_password
      fill_in 'Password', with: state[:password]
    end

    def and_i_enter_an_arbitrary_password
      fill_in 'Password', with: generate(:password)
    end

    def and_i_enter_a_new_password
      state[:new_password] = generate(:password)
      fill_in :user_password, with: state[:new_password]
      fill_in :user_password_confirmation, with: state[:new_password]
    end

    def when_i_click(label)
      click_button label
    end
    alias_method :and_i_click, :when_i_click

    def when_i_check(label)
      check label
    end
    alias_method :and_i_check, :when_i_check

    def then_i_should_have_a_new_password
      state[:me].reload
      expect(state[:me].authenticate(state[:new_password])).to eql(state[:me])
    end

    def then_i_should_see_an_invalid_token_message
      expect(page).to have_text("That doesn’t appear to be a valid token")
    end

    def and_no_email_should_be_sent
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end
end
