require 'rails_helper'

feature 'Submissions maintenance' do
  let(:me) { create(:user) }

  scenario 'Accept a feedback request' do
    visit token_url(build_token('no_response'))

    expect(page).to have_text 'You have 360 feedback requests from 1 colleague:'
    choose 'Accept'
    click_button 'Update'

    expect(Submission.last.status).to eql('started')
  end

  scenario 'Reject a feedback request' do
    visit token_url(build_token('no_response'))

    choose 'Reject'
    expect(page).to have_text 'Please explain why you have rejected the request'
    fill_in 'submission_rejection_reason', with: 'Some stuff'
    click_button 'Update'

    expect(Submission.last.rejection_reason).to eql('Some stuff')
    expect(Submission.last.status).to eql('started')
  end

  scenario 'Submit feedback' do
    visit token_url(build_token('started'))

    click_link 'Add feedback'

    choose 'Good'
    fill_in 'Achievements', with: 'Some good stuff'
    fill_in 'Improvements', with: 'Could learn to...'
    click_button 'Submit'

    submission = Submission.last
    expect(submission.rating).to eql('Good')
    expect(submission.achievements).to eql('Some good stuff')
    expect(submission.improvements).to eql('Could learn to...')
  end

  def build_token(status)
    create(:review, status: status).tokens.create
  end
end
