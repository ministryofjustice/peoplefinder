require 'rails_helper'

feature 'Submissions maintenance' do
  let(:me) { create(:user) }

  scenario 'Accept a feedback request' do
    visit token_url(build_token(:no_response))

    expect(page).to have_text 'You have 360 feedback requests from 1 colleague:'
    choose 'Accept'
    click_button 'Update'

    expect(Reply.last.status).to eql(:accepted)
    expect(page).to have_text('Thank you for accepting the invitation')
  end

  scenario 'Reject a feedback request' do
    visit token_url(build_token(:no_response))

    choose 'Reject'
    expect(page).to have_text 'Please explain why you have rejected the request'
    fill_in 'Rejection reason', with: 'Some stuff'
    click_button 'Update'

    expect(Reply.last.rejection_reason).to eql('Some stuff')
    expect(Reply.last.status).to eql(:rejected)

    expect(last_email.subject).to eql('Request for feedback has been rejected')
    expect(links_in_email(last_email).first).to match(%r{http:\/\/www.example.com\/go\/\w+-\w+-\w+-\w+-\w+})
  end

  scenario 'Accept a previously rejected feedback request' do
    visit token_url(build_token(:rejected))
    Reply.last.update_attributes(rejection_reason: 'Wrong button')

    click_button 'Accept request'

    expect(Reply.last.rejection_reason).to be_empty
    expect(Reply.last.status).to eql(:accepted)
  end

  def build_token(status)
    create(:review, status: status).tokens.create
  end
end
