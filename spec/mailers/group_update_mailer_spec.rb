require 'rails_helper'

RSpec.describe GroupUpdateMailer do
  include PermittedDomainHelper

  let(:recipient) { create(:person, email: 'test.user@digital.justice.gov.uk') }
  let(:person_responsible) { create(:person) }
  let(:group) { create(:person) }

  describe '.inform_subscriber' do
    let(:mail) {
      described_class.inform_subscriber(recipient, group, person_responsible).
        deliver_now
    }

    it 'includes the name of the group changed' do
      %w[plain html].each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text(group.name)
      end
    end

    it 'includes a link to the group changed' do
      %w[plain html].each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text(group_url(group))
      end
    end

    it 'includes the name of the person who changed the group' do
      %w[plain html].each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text(person_responsible.name)
      end
    end

    it 'is sent to the recipient' do
      expect(mail.to).to include(recipient.email)
    end
  end
end
