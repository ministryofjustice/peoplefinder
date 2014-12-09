require 'rails_helper'

feature 'Getting feedback' do
  let(:me) { create(:user, manager: create(:user)) }

  before do
    open_review_period
    ReviewPeriod.closes_at = Time.new(2020, 12, 9, 16, 30)
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

  scenario 'Invite a new person to give me feedback but omitting a field' do
    visit reviews_path
    fill_in 'Name', with: 'Danny Boy'
    fill_in 'Email address', with: 'danny@example.com'
    fill_in 'Message text', with: 'PLEASE FEED ME'
    click_button 'Send'

    expect(Review.all.count).to eql(0)
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

  scenario 'Invite a new person to give my direct report feedback' do
    direct_report = create(:user, manager: me)

    visit user_reviews_path(direct_report)
    fill_in_feedback_request_form

    review = direct_report.reviews.last
    check_review_attributes(review)

    check_mail_attributes(last_email, review)
  end

  scenario 'See the status of my feedback' do
    create :no_response_review,
      subject: me, author_name: 'Foxtrot', relationship: :peer
    create :started_review,
      subject: me, author_name: 'Golf', relationship: :supplier
    create :submitted_review,
      subject: me, author_name: 'Hotel', relationship: :customer

    visit reviews_path

    expect(page).to have_text('Foxtrot Peer Pending')
    expect(page).to have_text('Golf Supplier Started')
    expect(page).to have_text('Hotel Customer/stakeholder Completed')
  end

  scenario "See the status of my direct reports' feedback" do
    direct_report = create(:user, name: 'Joe Worker', manager: me)

    create :no_response_review,
      subject: direct_report, author_name: 'Foxtrot', relationship: :peer
    create :started_review,
      subject: direct_report, author_name: 'Golf', relationship: :supplier
    create :submitted_review,
      subject: direct_report, author_name: 'Hotel', relationship: :customer

    visit users_path
    click_link direct_report.name

    expect(page).to have_text('Foxtrot Peer Pending')
    expect(page).to have_text('Golf Supplier Started')
    expect(page).to have_text('Hotel Customer/stakeholder Completed')
  end

  scenario 'See feedback completed for me' do
    review = create(:submitted_review, author_name: 'Danny Boy', subject: me)
    visit reviews_path

    click_link 'View feedback'

    expect(page).to have_text("Feedback for #{me.name}")
    expect(page).to have_text('Given by Danny Boy')

    click_first_link 'Return to dashboard'
    expect(page).to have_link('View feedback', href: review_path(review))
  end

  scenario 'See feedback completed for my direct report' do
    direct_report = create(:user, manager: me, name: 'Marvin Managee')
    review = create(:submitted_review, author_name: 'Danny Boy', subject: direct_report)

    visit users_path

    within('#users') do
      click_link 'Marvin Managee'
    end

    click_link 'View feedback'

    expect(page).to have_text('Feedback for Marvin Managee')
    expect(page).to have_text('Given by Danny Boy')

    click_first_link 'Feedback for Marvin Managee'
    expect(page).to have_link('View feedback', href: polymorphic_path([direct_report, review]))
  end

  scenario 'See the list of my direct reports' do
    direct_report = create(:user, manager: me, name: 'Marvin Managee')
    create(:submitted_review, author_name: 'Danny Boy', subject: direct_report)
    create(:review, subject: direct_report)

    visit users_path

    expect(page).to have_text('You have one direct report who requires feedback')
    within('#users') do
      expect(page).to have_link('Marvin Managee', href: user_reviews_path(direct_report))
      expect(page).to have_text('1 of 2 complete')
    end
  end

  scenario 'As a user who is *not* a participant' do
    me.update participant: false
    visit reviews_path
    access_is_denied
  end

  def fill_in_feedback_request_form
    fill_in 'Name', with: 'Danny Boy'
    fill_in 'Email address', with: 'danny@example.com'
    select 'Peer', from: 'Working relationship'
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
    expect(mail.subject).to eq('360 feedback request from you')
    expect(mail.body.encoded).to match(review.invitation_message)
    expect(mail.body.encoded).to match('9 December 2020')
    link = links_in_email(mail).first
    expect(link).to eql(token_url(review.tokens.last))
  end
end
