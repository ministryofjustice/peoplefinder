require 'rails_helper'

feature 'Review maintenance' do
  let(:me) { create(:user) }

  before do
    token = create(:token, user: me)
    visit token_path(token)
  end

  scenario 'Invite a new person to give me feedback' do
    visit reviews_path
    fill_in_feedback_request_form

    review = me.reviews.last
    check_review_attributes(review)

    check_mail_attributes(last_email, review)
  end

  scenario 'Remind person to give me feedback' do
    create(:review, subject: me)

    visit reviews_path
    click_button 'Send reminder'

    review = me.reviews.last

    check_mail_attributes(last_email, review)
  end

  scenario 'Invite a new person to give my managee feedback' do
    managee = create(:user, manager: me)

    visit user_reviews_path(managee)
    fill_in_feedback_request_form

    review = managee.reviews.last
    check_review_attributes(review)

    check_mail_attributes(last_email, review)
  end

  scenario 'See feedback completed for me' do
    review = create(:review, submitted_review_attributes.merge(subject: me))
    visit reviews_path

    click_link 'Danny Boy'

    expect(page).to have_text('Feedback from Danny Boy')
    expect(page).to have_text(review.rating)
    expect(page).to have_text(review.achievements)
    expect(page).to have_text(review.improvements)

    click_link 'Back'
    expect(page).to have_link('Danny Boy', href: review_path(review))
  end

  scenario 'See feedback completed for my managee' do
    managee = create(:user, manager: me, name: 'Marvin Managee')
    review = create(:review, submitted_review_attributes.merge(subject: managee))

    visit users_path

    within('ul') do
      click_link 'Marvin Managee'
    end

    expect(page).to have_text('Direct report: Marvin Managee')
    click_link 'Danny Boy'

    expect(page).to have_text('Direct report: Marvin Managee')
    expect(page).to have_text('Feedback from Danny Boy')
    expect(page).to have_text(review.rating)
    expect(page).to have_text(review.achievements)
    expect(page).to have_text(review.improvements)

    click_link 'Back'
    expect(page).to have_link('Danny Boy', href: polymorphic_path([managee, review]))
    expect(page).to have_text('Direct report: Marvin Managee')
  end

  scenario 'As a user who is *not* a participant' do
    me.update_attributes participant: false
    visit reviews_path
    access_is_denied
  end

  def fill_in_feedback_request_form
    fill_in 'Name', with: 'Danny Boy'
    fill_in 'Email', with: 'danny@example.com'
    fill_in 'Relationship', with: 'Colleague'
    click_button 'Create'
  end

  def check_review_attributes(review)
    expect(review.author_name).to eql('Danny Boy')
    expect(review.author_email).to eql('danny@example.com')
    expect(review.relationship).to eql('Colleague')
  end

  def check_mail_attributes(mail, review)
    expect(mail.subject).to eq('Request for feedback')
    expect(mail.body.encoded).to match(/give me some feedback/)
    link = links_in_email(mail).first
    expect(link).to eql(token_url(review.tokens.last))
  end

  def submitted_review_attributes
    {
      author_name: 'Danny Boy',
      rating: 'Good',
      achievements: 'Something done well',
      improvements: 'Could be better',
      status: :submitted
    }
  end
end
