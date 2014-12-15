require 'rails_helper'

feature 'Reminders' do
  scenario 'Receiving an email near the end when I have outstanding feedback to receive' do
    me = create(:user)
    create(:no_response_review, subject: me)
    ReviewPeriod.closes_at = 8.5.days.from_now

    RemindersJob.perform_later

    mail = emails_for(me.email).last
    expect(mail.body).to have_text('Some people still haven’t responded')

    visit links_in_email(mail).first
    expect_logged_in_as(me.email)
  end
end
