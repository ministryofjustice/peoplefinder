require 'rails_helper'

feature 'Responding to feedback requests' do
  let(:token) { review.tokens.create }

  before do
    visit token_path(token)
  end

  context 'With a new request' do
    let(:review) { create(:no_response_review) }

    scenario 'Accept a feedback request' do
      expect(page).to have_text 'One person has asked you for feedback'
      choose 'Accept'
      click_button 'Update'

      expect(Review.last.status).to eql(:accepted)
      expect(page).to have_text('Thank you for accepting the invitation')
    end

    scenario 'Decline a feedback request with a reason' do
      choose 'Decline'
      fill_in 'Reason for declining', with: 'Some stuff'
      click_button 'Update'

      expect(Review.last.reason_declined).to eql('Some stuff')
      expect(Review.last.status).to eql(:declined)
    end

    scenario 'Decline a feedback request and email subject of declined status with reason' do
      choose 'Decline'
      reason = "I don't know you well enough to comment on your performance"
      fill_in 'Reason for declining', with: reason
      click_button 'Update'

      expect(last_email.subject).to eql('Request for feedback has been declined')
      expect(last_email.to.first).to eql(Review.last.subject.email)
      expect(last_email).to have_text("#{ Review.last.author_name } has declined")
      expect(email_contains(last_email, reason)).to include(reason)

      visit(links_in_email(last_email).first)
      within('#log-in-out') do
        expect(page).to have_text(Review.last.subject.email)
      end
    end

    scenario 'Attempt to decline a feedback request without a reason' do
      choose 'Decline'
      fill_in 'Reason for declining', with: ''
      click_button 'Update'

      expect(page).to have_text 'A reason is required when rejecting an invitation'
      expect(Review.last.reason_declined).to be_blank
      expect(Review.last.status).to eql(:no_response)
    end

    scenario 'Toggle display of the decline reason field', js: true do
      choose 'Decline'
      expect(page).to have_text 'Reason for declining'

      choose 'Accept'
      expect(page).not_to have_text 'Reason for declining'
    end
  end

  context 'With a previously declined request' do
    let(:review) { create(:declined_review) }

    scenario 'Accept a previously declined feedback request' do
      Review.last.update reason_declined: 'Wrong button'

      click_button 'Accept request'

      expect(Review.last.reason_declined).to be_empty
      expect(Review.last.status).to eql(:accepted)
    end
  end
end
