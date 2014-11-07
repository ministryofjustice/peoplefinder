require 'rails_helper'

feature 'Home page' do
  before do
    open_review_period
  end

  context 'When the review period is open' do
    scenario 'An administrator visiting the home page' do
      log_in_as create(:admin_user)
      expect(current_path).to eql(admin_path)
    end

    scenario 'A user with a manager visiting the home page' do
      manager = create(:user)
      user = create(:user, manager: manager)
      token = user.tokens.create

      visit token_url(token)
      visit root_path

      expect(current_path).to eql(reviews_path)
    end

    scenario 'A top-level manager visiting the home page' do
      manager = create(:user)
      create(:user, manager: manager)
      token = manager.tokens.create

      visit token_url(token)
      visit root_path

      expect(current_path).to eql(users_path)
    end

    scenario 'A review author visiting the home page' do
      author = create(:author)
      review = create(:review, author_email: author.email)
      token = review.tokens.create

      visit token_url(token)
      visit root_path

      expect(current_path).to eql(replies_path)
    end

    scenario 'An unauthenticated person visiting the home page' do
      visit root_path

      expect(current_path).to eql(root_path)
    end
  end
end
