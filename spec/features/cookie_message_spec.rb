require 'rails_helper'

feature 'Cookie message', js: true do
  let(:message_text) { 'GOV.UK uses cookies to make the site simpler' }

  scenario 'first visit' do
    visit '/'
    expect(page).to have_text(message_text)

    click_link 'Find out more about cookies'
    expect(page).to have_content('How cookies are used on People Finder')
  end

  scenario 'subsequent visits' do
    visit '/'
    visit '/'
    expect(page).not_to have_text(message_text)
  end
end
