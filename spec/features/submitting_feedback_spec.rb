require 'rails_helper'

feature 'Submitting feedback' do
  let(:me) { create(:user) }
  let(:review) { create(:review, status: :accepted) }
  let(:token) { review.tokens.create }

  before do
    open_review_period
  end

  scenario 'Submit feedback' do
    visit token_path(token)

    click_link 'Add feedback'

    expect(page).to have_link('Return to dashboard', href: replies_path)

    Review::RATING_FIELDS.each do |rating_field|
      within("#submission_#{ rating_field }") do
        choose '5'
      end
    end

    fill_in 'submission_leadership_comments', with: 'Some good stuff'
    fill_in 'submission_how_we_work_comments', with: 'Could learn to...'
    click_button 'Submit'

    expect(page).to have_link("a questionnaire", href: Rails.configuration.survey_url)

    submission = Review.last
    Review::RATING_FIELDS.each do |rating_field|
      expect(submission.send(rating_field)).to eql(5)
    end
    expect(submission.leadership_comments).to eql('Some good stuff')
    expect(submission.how_we_work_comments).to eql('Could learn to...')
    expect(submission.status).to eql(:submitted)

    click_link 'View feedback'
    expect(page).to have_text("Given by #{me.name}")
  end

  scenario 'Attempting to submit incomplete feedback' do
    visit token_path(token)
    click_link 'Add feedback'
    click_button 'Submit'

    expect(page).to have_text('Feedback not submitted')

    submission = Review.last
    expect(submission.status).not_to eql(:submitted)
  end

  scenario 'Autosave feedback', js: true do
    visit token_path(token)

    click_link 'Add feedback'

    within("#submission_rating_1") do
      choose '3'
    end
    fill_in 'submission_leadership_comments', with: 'Some good stuff'
    fill_in 'submission_how_we_work_comments', with: 'Could learn to...'

    expect(page).not_to have_text('All changes saved')

    sleep 0.2

    submission = Review.last
    expect(submission.rating_1).to eql(3)
    expect(submission.leadership_comments).to eql('Some good stuff')
    expect(submission.how_we_work_comments).to eql('Could learn to...')
    expect(submission.status).to eql(:started)

    expect(page).to have_text('All changes saved')
  end

  scenario 'View the leadership model' do
    visit token_path(token)

    click_link 'Add feedback'
    click_link 'Leadership Model'

    within('h1') do
      expect(page).to have_text('Leadership Model')
    end

    click_link 'Back'
    expect(page).to have_link('Leadership Model', href: leadership_model_path)
  end

  scenario 'View the MOJ story' do
    visit token_path(token)

    click_link 'Add feedback'
    click_link 'MOJ Story'

    within('h1') do
      expect(page).to have_text('MOJ Story')
    end

    click_link 'Back'
    expect(page).to have_link('MOJ Story', href: moj_story_path)
  end
end
