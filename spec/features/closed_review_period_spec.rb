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

    check_my_feedback_from_danny_boy
  end

  scenario 'As a manager with managees who has received feedback' do
    charlie = create(:user, name: 'Charlie', manager: me)
    create(:review, subject: charlie, author_name: 'Elena')

    visit token_path(me.tokens.create)

    check_my_feedback_from_danny_boy
    expect(page).to have_text('My direct reports')

    click_link('Charlie')
    expect(page).to have_text('Charlie\'s feedback')
    expect(page).to have_text('Feedback from Elena')

    click_link('My feedback')
    check_my_feedback_from_danny_boy
  end

  scenario 'As an author using a review token' do
    visit token_url(review.tokens.create)
    access_is_denied
  end

  def check_my_feedback_from_danny_boy
    expect(page).to have_text('Feedback report period has ended')
    expect(page).to have_text('Feedback from Danny Boy')
    expect(page).to have_text('Rating: ok')
    expect(page).to have_text('Some good stuff')
    expect(page).to have_text('Do better')
  end
end
