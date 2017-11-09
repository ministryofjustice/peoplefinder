require 'rails_helper'

RSpec.describe PersonDeletionRequestMailer do
  include PermittedDomainHelper

  let(:reporter) { create(:person, email: 'test.user@digital.justice.gov.uk') }
  let(:person) { create(:person) }
  let(:reported) { Time.now.to_i }
  let(:support_email) { Rails.configuration.support_email }
  let(:details_hash) do
    {
      reporter: reporter,
      person: person,
      note: 'They left the department last week.'
    }
  end

  describe '.deletion_request' do
    let(:mail) do
      described_class.deletion_request(details_hash).
        deliver_now
    end

    it 'is sent to support mailbox' do
      expect(mail.to).to include(support_email)
    end

    it 'sets reply-to to persons email for automated response' do
      expect(mail.reply_to).to include(reporter.email)
    end

    it 'has text part only' do
      expect(mail.multipart?).to be false
      expect(mail.content_type).to include 'text/plain'
    end

    it 'includes the name of the reporter' do
      expect(mail.body).to have_text(reporter.name)
    end

    it 'includes the email of the reporter' do
      expect(mail.body).to have_text(reporter.email)
    end

    it 'includes the name of the person' do
      expect(mail.body).to have_text(person.name)
    end

    it "includes the URL to the person's profile" do
      expect(mail.body).to have_text(person_url(person))
    end
  end
end
