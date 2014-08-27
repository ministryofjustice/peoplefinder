require 'rails_helper'

feature 'Review maintenance' do
  let(:me) { create(:user) }

  before do
    token = create(:token, user: me)
    visit token_path(token)
  end

  scenario 'Invite a new person to give me feedback' do
    create_a_feedback_request

    review = me.reviews_received.last
    expect(review.author_name).to eql('Danny Boy')
    expect(review.author_email).to eql('danny@example.com')
    expect(review.relationship).to eql('Colleague')

    mail = last_email
    expect(mail.subject).to eq('Request for feedback')

    link = links_in_email(mail).first
    expect(link).to eql(token_url(review.tokens.last))
  end

  scenario 'Invite a new person to give my managee feedback' do
    managee = create(:user, manager: me)

    visit user_reviews_path(managee)

    fill_in 'Name', with: 'Danny Boy'
    fill_in 'Email', with: 'danny@example.com'
    fill_in 'Relationship', with: 'Colleague'
    click_button 'Create'

    review = managee.reviews_received.last
    expect(review.author_name).to eql('Danny Boy')
    expect(review.author_email).to eql('danny@example.com')
    expect(review.relationship).to eql('Colleague')

    mail = last_email
    expect(mail.subject).to eq('Request for feedback')

    link = links_in_email(mail).first
    expect(link).to eql(token_url(review.tokens.last))
  end

  scenario 'Accept a feedback request' do
    create_a_feedback_request

    visit token_url(Token.last)
    select 'accept', from: 'Status'
    click_button 'Update'

    expect(Review.last).to be_accepted
  end

  scenario 'Decline a feedback request' do
    create_a_feedback_request

    visit token_url(Token.last)
    select 'decline', from: 'Status'
    click_button 'Update'

    expect(Review.last).to be_declined
  end

  def create_a_feedback_request
    visit reviews_path

    fill_in 'Name', with: 'Danny Boy'
    fill_in 'Email', with: 'danny@example.com'
    fill_in 'Relationship', with: 'Colleague'
    click_button 'Create'
  end
end
