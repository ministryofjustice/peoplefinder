require 'rails_helper'

feature 'Introduction to the system' do

  let(:user) { create(:user) }

  scenario 'Receiving an introductory email and getting in' do
    Introduction.new(user).send
    mail = ActionMailer::Base.deliveries.last
    body = mail.body.encoded
    link = body[/http\S+/]
    visit link
    expect(page).to have_content("#{user}’s dashboard")
  end
end
