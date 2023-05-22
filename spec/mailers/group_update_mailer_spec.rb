require 'rails_helper'

RSpec.describe GroupUpdateMailer do
  include PermittedDomainHelper

  let(:recipient) { create(:person, email: 'test.user@digital.justice.gov.uk') }
  let(:instigator) { create(:person) }
  let(:group) { create(:person) }

  describe '.inform_subscriber' do
    let(:mail) do
      described_class.inform_subscriber(recipient, group, instigator)
    end

    it 'sets the template' do
      expect(mail.govuk_notify_template).to eq 'fabc29b0-084d-481c-95eb-09eebe4fcd29'
    end

    it 'is sent to requestor' do
      expect(mail.to).to include(recipient.email)
    end

    it 'sets the personalisation data' do
      expect(mail.govuk_notify_personalisation[:group]).to eq group.to_s
      expect(mail.govuk_notify_personalisation[:group_url]).to eq group_url(group)
      expect(mail.govuk_notify_personalisation[:instigator_email]).to eq instigator.email
      expect(mail.govuk_notify_personalisation[:name]).to eq recipient.given_name
    end
  end
end
