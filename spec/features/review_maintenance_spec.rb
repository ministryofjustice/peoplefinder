require 'rails_helper'

feature 'Review maintenance' do
  let(:me) { create(:user, manager: create(:user)) }

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

  scenario 'Invite a person that has already been invited' do
    visit reviews_path
    fill_in_feedback_request_form
    fill_in_feedback_request_form

    expect(Review.all.count).to eql(1)
    expect(page).to have_text('already been invited')
  end

  scenario 'Submit feedback request with invalid data' do
    visit reviews_path

    click_button 'Send'
    expect(page).to have_text('check the errors below')
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

    click_link 'View feedback'

    expect(page).to have_text('Feedback from Danny Boy')
    expect(page).to have_text(review.rating)
    expect(page).to have_text(review.achievements)
    expect(page).to have_text(review.improvements)

    click_link 'Back'
    expect(page).to have_link('View feedback', href: review_path(review))
  end

  scenario 'See feedback completed for my managee' do
    managee = create(:user, manager: me, name: 'Marvin Managee')
    review = create(:review, submitted_review_attributes.merge(subject: managee))

    visit users_path

    within('#users') do
      click_link 'Marvin Managee'
    end

    expect(page).to have_text('Direct report: Marvin Managee')
    click_link 'View feedback'

    expect(page).to have_text('Direct report: Marvin Managee')
    expect(page).to have_text('Feedback from Danny Boy')
    expect(page).to have_text(review.rating)
    expect(page).to have_text(review.achievements)
    expect(page).to have_text(review.improvements)

    click_link 'Back'
    expect(page).to have_link('View feedback', href: polymorphic_path([managee, review]))
    expect(page).to have_text('Direct report: Marvin Managee')
  end

  scenario 'See the list of my managees' do
    managee = create(:user, manager: me, name: 'Marvin Managee')
    create(:review, submitted_review_attributes.merge(subject: managee))
    create(:review, subject: managee)

    visit users_path

    expect(page).to have_text('You have one direct report who requires feedback')
    within('#users') do
      expect(page).to have_link('Marvin Managee', href: user_reviews_path(managee))
      expect(page).to have_text('1 of 2 complete')
    end
  end

  scenario 'As a user who is *not* a participant' do
    me.update_attributes participant: false
    visit reviews_path
    access_is_denied
  end

  def fill_in_feedback_request_form
    fill_in 'Name', with: 'Danny Boy'
    fill_in 'Email address', with: 'danny@example.com'
    select 'Peer', from: 'Your working relationship'
    fill_in 'Message text', with: 'PLEASE FEED ME'
    click_button 'Send'
  end

  def check_review_attributes(review)
    expect(review.author_name).to eql('Danny Boy')
    expect(review.author_email).to eql('danny@example.com')
    expect(review.relationship).to eql(:peer)
    expect(review.invitation_message).to eql('PLEASE FEED ME')
  end

  def check_mail_attributes(mail, review)
    expect(mail.subject).to eq('Request for feedback')
    expect(mail.body.encoded).to match(review.invitation_message)
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
