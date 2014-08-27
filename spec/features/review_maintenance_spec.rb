require 'rails_helper'

feature 'Review maintenance' do
  let(:me) { create(:user) }

  before do
    token = create(:token, user: me)
    visit token_path(token)
  end

  scenario 'Invite a new person to give me feedback' do
    visit reviews_path

    fill_in 'Name', with: 'Danny Boy'
    fill_in 'Email', with: 'danny@example.com'
    fill_in 'Relationship', with: 'Colleague'
    click_button 'Create'

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
end
