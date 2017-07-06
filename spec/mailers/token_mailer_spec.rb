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
      described_class.new_token_email(token).
        deliver_now
    end

    it 'is sent to requestor' do
      expect(mail.to).to include(requestor.email)
    end

    it 'has text and html part' do
      expect(mail.multipart?).to be true
      expect(mail.content_type).to include('multipart/alternative')
    end

    it 'includes the browser warning' do
      %w(plain html).each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text('Internet Explorer 6 and 7 users')
      end
    end

    it 'includes the app guidance' do
      %w(plain html).each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text('Find out more about how to use People Finder on the')
        expect(get_message_part(mail, part_type)).to have_text('https://intranet.justice.gov.uk/peoplefinder') if part_type == 'plain'
        expect(get_message_part(mail, part_type)).to have_link('MoJ Intranet', href: 'https://intranet.justice.gov.uk/peoplefinder') if part_type == 'html'
      end
    end

    it 'includes the do not reply warning' do
      %w(plain html).each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text('This email is automatically generated. Do not reply')
      end
    end

    context 'probation users' do
      let(:requestor) { create(:person, email: 'requestor@probation.gsi.gov.uk') }

      it 'has text part only for probation email' do
        expect(mail.multipart?).to be false
        expect(mail.content_type).to include 'text/plain'
      end
    end
  end
end
