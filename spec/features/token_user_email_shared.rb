require 'rails_helper'

RSpec.shared_examples "it received a valid request from" do
  it "and sends the email" do
    delivery_count = sent_to.blank? ? 0 : 1
    visit '/'
    fill_in 'token_user_email', with: email
    expect { click_button 'Request link' }.to change { ActionMailer::Base.deliveries.count }.by(delivery_count)
    expect(page).to have_text('We’re just emailing you a link to access People Finder')

    unless sent_to.blank?
      expect(last_email.to).to eql([sent_to])
      expect(last_email.body.encoded).to have_text(token_url(Token.last))
    end
  end
end
