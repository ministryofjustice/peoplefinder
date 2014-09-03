require 'rails_helper'

feature 'Closed review period' do
  let(:me) { create(:user) }
  let!(:review) { create(:review, subject: me) }

  before(:each) { ENV['REVIEW_PERIOD'] = 'CLOSED' }
  after(:each) { ENV['REVIEW_PERIOD'] = nil }

  scenario 'As the subject of a review' do
    ReviewPeriod.new.send_closure_notifications
    visit links_in_email(last_email).first
    expect(page).to have_text('Feedback report period has ended')
  end

  scenario 'As an author using a review token' do
    visit token_url(review.tokens.create)
    expect(page).to have_text('Feedback report period has ended')
  end
end
