require 'rails_helper'

describe ReviewMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  include Rails.application.routes.url_helpers

  describe 'feedback request email' do
    let(:token) { '123456789' }
    let(:author_name) { 'Author' }
    let(:author_email) { 'banana@tropicalfruits.com' }
    let(:subject_name) { 'Subject' }
    let(:invitation_message) { "Dogs barking can't fly without umbrella" }
    let(:subject) { double(:subject, name: subject_name) }
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

    it 'has a login link with the provided token' do
      expect(email).to have_body_text token_url(token)
    end

    it 'contains the name of the review subject' do
      expect(email).to have_body_text review.subject.name
    end

  end

end
