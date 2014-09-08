require 'rails_helper'

feature 'Submitting feedback' do
  let(:me) { create(:user) }

  scenario 'Submit feedback' do
    visit token_path(build_token(:accepted))

    click_link 'Add feedback'

    choose 'Good'
    fill_in 'Achievements', with: 'Some good stuff'
    fill_in 'Improvements', with: 'Could learn to...'
    click_button 'Submit'

    submission = Submission.last
    expect(submission.rating).to eql('Good')
    expect(submission.achievements).to eql('Some good stuff')
    expect(submission.improvements).to eql('Could learn to...')
    expect(submission.status).to eql(:submitted)
  end

  scenario 'Autosave feedback', js: true do
    visit token_path(build_token(:accepted))

    click_link 'Add feedback'

    choose 'Good'
    fill_in 'Achievements', with: 'Some good stuff'
    fill_in 'Improvements', with: 'Could learn to...'
    sleep 0.2

    submission = Submission.last
    expect(submission.rating).to eql('Good')
    expect(submission.achievements).to eql('Some good stuff')
    expect(submission.improvements).to eql('Could learn to...')
    expect(submission.status).to eql(:started)
  end

  scenario 'View the leadership model' do
    visit token_url(build_token(:accepted))

    click_link 'Add feedback'
    click_link 'Leadership model'

    within('h2') do
      expect(page).to have_text('Leadership Model')
    end

    click_link 'Back'
    expect(page).to have_link('Leadership model', href: leadership_model_path)
  end

  def build_token(status)
    create(:review, status: status).tokens.create
  end
end
