require 'rails_helper'

describe ReviewMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  include Rails.application.routes.url_helpers

  before do
    open_review_period
  end

  let(:token) { '123456789' }
  let(:subject_name) { 'Subject' }
  let(:subject_email) { 'pineapple@tropicalfruits.com' }
  let(:subject) { double(:subject, name: subject_name, email: subject_email) }
  let(:author_name) { 'Author' }

  describe 'feedback request email' do
    let(:author_email) { 'banana@tropicalfruits.com' }
    let(:invitation_message) { "Dogs barking can't fly without umbrella" }
    let(:review) { double(author_name: author_name,
                          author_email: author_email,
                          invitation_message: invitation_message,
                          subject: subject)
    }
    let(:email) { described_class.feedback_request(review, token) }

    it 'is sent to the requested review author' do
      expect(email.to.first).to eql review.author_email
    end

    it 'contains provided invitation message' do
      expect(email).to have_body_text review.invitation_message
    end

    it 'contains a login link with the provided token' do
      expect(email).to have_body_text token_url(token)
    end

    it 'contains the name of the review subject' do
      expect(email).to have_body_text review.subject.name
    end
  end

  describe 'request declined email' do
    let(:reason_declined) { 'You can find your way across this country using burger joints' }
    let(:review) { double(author_name: author_name, reason_declined: reason_declined, subject: subject) }
    let(:email) { described_class.request_declined(review, token) }

    it 'is sent to the feedback subject' do
      expect(email.to.first).to eql review.subject.email
    end

    it 'contains the recipients name' do
      expect(email).to have_body_text review.subject.name
    end

    it 'contains the reason for declining the request' do
      expect(email).to have_body_text review.reason_declined
    end

    it 'contains a login link with the provided token' do
      expect(email).to have_body_text token_url(token)
    end
  end

  describe 'feedback submission email' do
    let(:review) { double(id: 27, author_name: author_name, subject: subject) }
    let(:email) { described_class.feedback_submission(review, token) }

    it 'is sent to the feedback subject' do
      expect(email.to.first).to eql review.subject.email
    end

    it 'contains the recipients name' do
      expect(email).to have_body_text review.subject.name
    end

    it 'contains the authors name' do
      expect(email).to have_body_text review.author_name
    end

    it 'contains a login link with the provided token' do
      expect(email).to have_body_text token_url(token)
    end
  end

end
