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
    expect(Submission.last.status).to eql('rejected')
  end

  scenario 'Accept a previously rejected feedback request' do
    visit token_url(build_token('rejected'))
    Submission.last.update_attributes(rejection_reason: 'Wrong button')

    click_button 'Accept request'

    expect(Submission.last.rejection_reason).to be_empty
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

  scenario 'View the leadership model' do
    visit token_url(build_token('started'))

    click_link 'Add feedback'
    click_link 'Leadership model'

    within('h1') do
      expect(page).to have_text('Leadership Model')
    end

    click_link 'Back'
    expect(page).to have_link('Leadership model', href: leadership_model_path)
  end

  def build_token(status)
    create(:review, status: status).tokens.create
  end
end
