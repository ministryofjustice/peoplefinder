require 'rails_helper'

feature 'Review maintenance' do
  before do
    token = create(:token, user: create(:user))
    visit token_path(token)
  end

  scenario 'Invite a new person to give me feedback' do
    visit reviews_path

    fill_in 'Name', with: 'Danny Boy'
    fill_in 'Email', with: 'danny@example.com'
    fill_in 'Relationship', with: 'Colleague'
    click_button 'Create'

    review = Review.last
    expect(review.author_name).to eql('Danny Boy')
    expect(review.author_email).to eql('danny@example.com')
    expect(review.relationship).to eql('Colleague')

    mail = ActionMailer::Base.deliveries.last
    expect(mail.subject).to eq('Request for feedback')
    expect(mail).to have_text(token_path(review.tokens.last))
  end
end
