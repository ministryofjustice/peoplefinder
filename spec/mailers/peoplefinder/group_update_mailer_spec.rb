require 'rails_helper'

RSpec.configure do |c|
  c.include Peoplefinder::Engine.routes.url_helpers
end

RSpec.describe Peoplefinder::GroupUpdateMailer do
  let(:recipient) { create(:person, email: 'test.user@digital.justice.gov.uk') }
  let(:person_responsible) { create(:person) }
  let(:group) { create(:person) }

  describe '.inform_subscriber' do
    let(:mail) {
      described_class.inform_subscriber(recipient, group, person_responsible).
        deliver_now
    }

    it 'includes the name of the group changed' do
      expect(mail.body).to have_text(group.name)
    end

    it 'includes a link to the group changed' do
      expect(mail.body).to have_text(group_url(group))
    end

    it 'includes the name of the person who changed the group' do
      expect(mail.body).to have_text(person_responsible.name)
    end

    it 'is sent to the recipient' do
      expect(mail.to).to include(recipient.email)
    end
  end
end
