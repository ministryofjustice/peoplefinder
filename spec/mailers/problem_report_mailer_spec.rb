require "rails_helper"

RSpec.describe ProblemReportMailer do
  include PermittedDomainHelper

  let(:reporter) { create(:person, email: "test.user@digital.justice.gov.uk") }
  let(:reported) { Time.zone.now.to_i }
  let(:support_email) { Rails.configuration.support_email }
  let(:details_hash) do
    {
      goal: "Something daft",
      problem: "It broke",
      ip_address: "255.255.255.255",
      person_email: reporter.email,
      person_id: reporter.id,
      browser: "IE99",
      timestamp: reported,
    }
  end

  describe ".problem_report" do
    let(:mail) do
      described_class.problem_report(details_hash)
    end

    it "sets the template" do
      expect(mail.govuk_notify_template).to eq "edd53a46-569e-40bf-8639-ceaecabddafd"
    end

    it "is sent to support mailbox" do
      expect(mail.to).to include(support_email)
    end

    it "sets the personalisation data" do
      expect(mail.govuk_notify_personalisation[:browser]).to eq "IE99"
      expect(mail.govuk_notify_personalisation[:ip_address]).to eq "255.255.255.255"
      expect(mail.govuk_notify_personalisation[:person_email]).to eq reporter.email
      expect(mail.govuk_notify_personalisation[:person_id]).to eq reporter.id
      expect(mail.govuk_notify_personalisation[:problem]).to eq "It broke"
      expect(mail.govuk_notify_personalisation[:reported_at]).to eq Time.zone.at(reported).utc.iso8601
      expect(mail.govuk_notify_personalisation[:trying_to_do]).to eq "Something daft"
    end

    context "without reporter details" do
      let(:details_hash) do
        {
          goal: "Something daft",
          problem: "It broke",
          ip_address: "255.255.255.255",
          browser: "IE99",
          timestamp: reported,
        }
      end

      it "includes unknown for ID" do
        expect(mail.govuk_notify_personalisation[:person_id]).to eq "unknown"
      end

      it "includes unknown for email" do
        expect(mail.govuk_notify_personalisation[:person_email]).to eq "unknown"
      end
    end
  end
end
