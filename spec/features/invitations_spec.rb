require 'rails_helper'

feature 'Invitations' do
  scenario 'Accept a feedback request' do
    visit token_url(build_token(:no_response))

    expect(page).to have_text 'You have 360 feedback requests from 1 colleague:'
    choose 'Accept'
    click_button 'Update'

    expect(Reply.last.status).to eql(:accepted)
    expect(page).to have_text('Thank you for accepting the invitation')
  end

  scenario 'Decline a feedback request with a reason' do
    visit token_url(build_token(:no_response))

    choose 'Decline'
    expect(page).to have_text 'Please explain why you have declined the request'
    fill_in 'Reason declined', with: 'Some stuff'
    click_button 'Update'

    expect(Reply.last.reason_declined).to eql('Some stuff')
    expect(Reply.last.status).to eql(:declined)
  end

  scenario 'Decline a feedback request and email subject of declined status' do
    visit token_url(build_token(:no_response))

    choose 'Decline'
    expect(page).to have_text 'Please explain why you have declined the request'
    fill_in 'Reason declined', with: 'Some stuff'
    click_button 'Update'

    expect(last_email.subject).to eql('Request for feedback has been declined')
    expect(last_email.to.first).to eql(Reply.last.subject.email)
    expect(last_email).to have_text("#{ Reply.last.author_name } has declined")

    visit(links_in_email(last_email).first)
    within('#log-in-out') do
      expect(page).to have_text(Reply.last.subject.email)
    end
  end

  scenario 'Attempt to decline a feedback request without a reason' do
    visit token_url(build_token(:no_response))

    choose 'Decline'
    expect(page).to have_text 'Please explain why you have declined the request'
    fill_in 'Reason declined', with: ''
    click_button 'Update'

    expect(page).to have_text 'A reason is required when rejecting an invitation'
    expect(Reply.last.reason_declined).to be_blank
    expect(Reply.last.status).to eql(:no_response)
  end

  scenario 'Toggle display of the decline reason field', js: true do
    visit token_path(build_token(:no_response))

    choose 'Decline'
    expect(page).to have_text 'Please explain'

    choose 'Accept'
    expect(page).not_to have_text 'Please explain'
  end

  scenario 'Accept a previously declined feedback request' do
    visit token_url(build_token(:declined))
    Reply.last.update_attributes(reason_declined: 'Wrong button')

    click_button 'Accept request'

    expect(Reply.last.reason_declined).to be_empty
    expect(Reply.last.status).to eql(:accepted)
  end

  def build_token(status)
    create(:review, status: status).tokens.create
  end
end
