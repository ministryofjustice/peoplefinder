require 'rails_helper'

RSpec.describe TokenMailer do
  include PermittedDomainHelper

  before do
    PermittedDomain.find_or_create_by(domain: 'probation.gsi.gov.uk')
  end

  let(:requestor) { create(:person, email: 'requestor@digital.justice.gov.uk') }
  let(:token) { Token.new(user_email: requestor.email) }

  describe '.new_token_email' do
    let(:mail) do
      described_class.new_token_email(token)
    end

    it 'sets the template' do
      expect(mail.govuk_notify_template).to eq '539c30de-c483-4002-b7b1-b84d1bbaa6ac'
    end

    it 'is sent to requestor' do
      expect(mail.to).to include(requestor.email)
    end

    it 'sets the personalisation keys' do
      expect(mail.govuk_notify_personalisation.keys.sort).to eq [
        :token_url
      ]
    end
  end
end
