require 'rails_helper'

feature 'Closed review period' do
  let(:me) { create(:user) }
  let!(:review) do
    create(:submitted_review,
      subject: me,
      author_name: 'Danny Boy',
      leadership_comments: 'IS A LEADER'
    )
  end

  before do
    close_review_period
  end

  scenario 'Viewing my feedback' do
    me.update manager: create(:user)
    ReviewPeriod.send_closure_notifications
    visit links_in_email(last_email).first

    check_my_feedback_from_danny_boy
  end

  scenario 'Downloading my feedback' do
    me.update manager: create(:user)
    ReviewPeriod.send_closure_notifications
    visit links_in_email(last_email).first

    click_link 'Download as CSV'

    expect(page.response_headers['Content-Disposition']).to match('attachment')
    expect(page.body).to match(/\AName,#{me.name}/)
  end

  scenario 'Viewing the feedback of my direct report' do
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

  scenario 'Downloading the feedback of all my direct reports' do
    me.update manager: create(:user)
    charlie = create(:user, name: 'Charlie', manager: me)
    create :submitted_review, subject: charlie
    daniela = create(:user, name: 'Daniela', manager: me)
    create :submitted_review, subject: daniela

    visit token_path(me.tokens.create)
    click_link('Your direct reports')

    click_link 'Download as CSV'

    expect(page.response_headers['Content-Disposition']).to match('attachment')
    expect(page.body).to match(/^Name,Charlie$/)
    expect(page.body).to match(/^Name,Daniela$/)
  end

  scenario 'Visiting as a reviewer' do
    visit token_url(review.tokens.create)
    access_is_denied
  end

  def check_my_feedback_from_danny_boy
    expect(page).to have_text('Danny Boy IS A LEADER')
  end
end
