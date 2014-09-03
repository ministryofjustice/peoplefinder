require 'rails_helper'

feature 'Closed review period', closed_review_period: true do
  let(:me) { create(:user) }
  let!(:review) do
    create(:review, subject: me,
                    author_name: 'Danny Boy',
                    rating: 'ok',
                    achievements: 'Some good stuff',
                    improvements: 'Do better')
  end

  scenario 'As the subject of a review' do
    ReviewPeriod.new.send_closure_notifications
    visit links_in_email(last_email).first
    expect(page).to have_text('Feedback report period has ended')
    expect(page).to have_text('Feedback from Danny Boy')
    expect(page).to have_text('Rating: ok')
    expect(page).to have_text('Some good stuff')
    expect(page).to have_text('Do better')
  end

  scenario 'As an author using a review token' do
    visit token_url(review.tokens.create)
    expect(page).to have_text('Feedback report period has ended')
  end
end
