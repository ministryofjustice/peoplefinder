require 'rails_helper'

feature 'Submitting feedback' do
  let(:me) { create(:user) }

  scenario 'Submit feedback' do
    visit token_path(build_token(:accepted))

    click_link 'Add feedback'

    expect(page).to have_link('Return to dashboard', href: replies_path)

    Review::RATING_FIELDS.each do |rating_field|
      within("#submission_#{ rating_field }") do
        choose '3'
      end
    end

    fill_in 'submission_leadership_comments', with: 'Some good stuff'
    fill_in 'submission_how_we_work_comments', with: 'Could learn to...'
    click_button 'Submit'

    submission = Submission.last
    Review::RATING_FIELDS.each do |rating_field|
      expect(submission.send(rating_field)).to eql(3)
    end
    expect(submission.leadership_comments).to eql('Some good stuff')
    expect(submission.how_we_work_comments).to eql('Could learn to...')
    expect(submission.status).to eql(:submitted)

    click_link 'View feedback'
    expect(page).to have_text("Given by #{me.name}")
  end

  scenario 'Autosave feedback', js: true do
    visit token_path(build_token(:accepted))

    click_link 'Add feedback'

    within("#submission_rating_1") do
      choose '3'
    end
    fill_in 'submission_leadership_comments', with: 'Some good stuff'
    fill_in 'submission_how_we_work_comments', with: 'Could learn to...'

    expect(page).not_to have_text('All changes saved')

    sleep 0.2

    submission = Submission.last
    expect(submission.rating_1).to eql(3)
    expect(submission.leadership_comments).to eql('Some good stuff')
    expect(submission.how_we_work_comments).to eql('Could learn to...')
    expect(submission.status).to eql(:started)

    expect(page).to have_text('All changes saved')
  end

  scenario 'View the leadership model' do
    visit token_url(build_token(:accepted))

    click_link 'Add feedback'
    click_link 'Leadership Model'

    within('h1') do
      expect(page).to have_text('Leadership Model')
    end

    click_link 'Back'
    expect(page).to have_link('Leadership Model', href: leadership_model_path)
  end

  scenario 'View the MOJ story' do
    visit token_url(build_token(:accepted))

    click_link 'Add feedback'
    click_link 'MOJ Story'

    within('h1') do
      expect(page).to have_text('MOJ Story')
    end

    click_link 'Back'
    expect(page).to have_link('MOJ Story', href: moj_story_path)
  end

  def build_token(status)
    create(:review, status: status).tokens.create
  end
end
