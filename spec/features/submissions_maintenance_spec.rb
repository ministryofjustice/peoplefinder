require 'rails_helper'

feature 'Submissions maintenance' do
  let(:me) { create(:user) }
  let(:submission) { create(:submission, author: me) }
  let(:token) { create(:token, review: submission) }

  before do
    visit token_url(token)
  end

  scenario 'Submit feedback' do
    click_link 'Add feedback'

    expect(page).to have_text(submission.subject.name)

    choose 'Good'
    fill_in 'Achievements', with: 'Some good stuff'
    fill_in 'Improvements', with: 'Could learn to...'
    click_button 'Submit'

    review = Review.last
    expect(review.rating).to eql('Good')
    expect(review.achievements).to eql('Some good stuff')
    expect(review.improvements).to eql('Could learn to...')
  end
end
