require 'rails_helper'

RSpec.describe ProblemReportMailer do
  include PermittedDomainHelper

  let(:reporter) { create(:person, email: 'test.user@digital.justice.gov.uk') }
  let(:reported) { Time.now.to_i }
  let(:support_email) { Rails.configuration.support_email }
  let(:details_hash) do
    {
      goal: 'Something daft',
      problem: 'It broke',
      ip_address: '255.255.255.255',
      person_email: reporter.email,
      person_id: reporter.id,
      browser: 'IE99',
      timestamp: reported
    }
  end

  describe '.problem_report' do
    let(:mail) do
      described_class.problem_report(details_hash).
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

    it 'includes the email of the reporter when provided' do
      expect(mail.body).to have_text(reporter.email)
    end

    it 'includes the IP address of the reporter' do
      expect(mail.body).to have_text('255.255.255.255')
    end

    it 'includes the date reported in UTC iso8601 format' do
      expect(mail.body).to have_text(Time.at(reported).utc.iso8601)
    end

    it 'includes the user agent details' do
      expect(mail.body).to have_text('IE99')
    end

    context 'without reporter details' do
      let(:details_hash) do
        {
          goal: 'Something daft',
          problem: 'It broke',
          ip_address: '255.255.255.255',
          browser: 'IE99',
          timestamp: reported
        }
      end

      it 'does not set reply to' do
        expect(mail.reply_to).to be_empty
      end

      it 'includes unknown for ID' do
        expect(mail.body).to have_text('Person ID: unknown')
      end

      it 'includes unknown for email' do
        expect(mail.body).to have_text('Email: unknown')
      end
    end

  end
end
