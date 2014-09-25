require 'rails_helper'

feature 'Closed review period', closed_review_period: true do
  let(:me) { create(:user) }
  let!(:review) do
    create(:submitted_review,
      subject: me,
      author_name: 'Danny Boy',
      leadership_comments: 'IS A LEADER'
    )
  end

  scenario 'As the subject of a review' do
    me.update manager: create(:user)
    ReviewPeriod.new.send_closure_notifications
    visit links_in_email(last_email).first

    check_my_feedback_from_danny_boy
  end

  scenario 'As a manager with direct reports who has received feedback' do
    me.update manager: create(:user)
    charlie = create(:user, name: 'Charlie', manager: me)
    create(:submitted_review,
      subject: charlie,
      author_name: 'Elena',
      how_we_work_comments: 'WE WORK'
    )

    visit token_path(me.tokens.create)

    check_my_feedback_from_danny_boy

    click_link('Your direct reports')
    click_link('Charlie')
    expect(page).to have_text('All feedback for Charlie')
    expect(page).to have_text('Elena WE WORK')

    click_first_link('Return to dashboard')
    click_first_link('Your feedback')
    check_my_feedback_from_danny_boy
  end

  scenario 'As an author using a review token' do
    visit token_url(review.tokens.create)
    access_is_denied
  end

  def check_my_feedback_from_danny_boy
    expect(page).to have_text('Danny Boy IS A LEADER')
  end
end
